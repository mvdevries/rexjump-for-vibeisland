import Foundation
import Darwin

final class RexConnection {
    private let fd: Int32
    private var buffer = [UInt8]()
    private var counter = 0

    init(path: String) throws {
        fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { throw Failure("failed to create socket") }
        var address = sockaddr_un()
        address.sun_family = sa_family_t(AF_UNIX)
        let bytes = Array(path.utf8CString)
        guard bytes.count <= MemoryLayout.size(ofValue: address.sun_path) else {
            close(fd)
            throw Failure("socket path too long")
        }
        withUnsafeMutableBytes(of: &address.sun_path) { target in
            for (index, byte) in bytes.enumerated() { target[index] = UInt8(bitPattern: byte) }
        }
        let result = withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(fd, $0, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        guard result == 0 else {
            close(fd)
            throw Failure("failed to connect to Rex")
        }
        var timeout = timeval(tv_sec: 5, tv_usec: 0)
        setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
        do {
            try handshake()
            try hello()
        } catch {
            close(fd)
            throw error
        }
    }

    deinit { close(fd) }

    func call(_ method: String, _ payload: [String: Any] = [:]) throws -> [String: Any] {
        counter += 1
        let id = String(counter)
        try send(["type": "request", "id": id, "method": method, "payload": payload])
        while true {
            let message = try receive()
            guard message["type"] as? String == "response", message["id"] as? String == id else { continue }
            if let error = message["error"] as? [String: Any] {
                throw Failure("\(method): \(error["message"] as? String ?? "unknown error")")
            }
            return message["payload"] as? [String: Any] ?? [:]
        }
    }

    private func writeAll(_ data: [UInt8]) throws {
        var sent = 0
        while sent < data.count {
            let count = data[sent...].withUnsafeBytes { write(fd, $0.baseAddress, $0.count) }
            guard count > 0 else { throw Failure("failed to write to Rex") }
            sent += count
        }
    }

    private func take(_ count: Int) throws -> [UInt8] {
        while buffer.count < count {
            var chunk = [UInt8](repeating: 0, count: 65536)
            let received = read(fd, &chunk, chunk.count)
            guard received > 0 else { throw Failure("connection to Rex closed") }
            buffer.append(contentsOf: chunk[0..<received])
        }
        let result = Array(buffer[0..<count])
        buffer.removeFirst(count)
        return result
    }

    private func handshake() throws {
        let key = Data((0..<16).map { _ in UInt8.random(in: 0...255) }).base64EncodedString()
        let request = "GET /api/control HTTP/1.1\r\nHost: localhost\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: \(key)\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Protocol: rex.control.v1\r\n\r\n"
        try writeAll(Array(request.utf8))
        var head = [UInt8]()
        let terminator: [UInt8] = [13, 10, 13, 10]
        while !head.suffix(4).elementsEqual(terminator) {
            head += try take(1)
            guard head.count < 8192 else { throw Failure("unexpected response from Rex") }
        }
        let status = String(decoding: head, as: UTF8.self).components(separatedBy: "\r\n").first ?? ""
        guard status.contains(" 101 ") else { throw Failure("handshake refused: \(status)") }
    }

    private func hello() throws {
        try send(["type": "hello", "api_revision": 10, "client": ["kind": "other", "name": "RexJump for VibeIsland", "version": "1"]])
        let welcome = try receive()
        guard welcome["type"] as? String == "welcome" else { throw Failure("no welcome from Rex") }
    }

    private func send(_ object: [String: Any]) throws {
        let data = [UInt8](try JSONSerialization.data(withJSONObject: object))
        let length = data.count
        var frame: [UInt8] = [0x81]
        if length < 126 {
            frame.append(UInt8(0x80 | length))
        } else if length < 65536 {
            frame.append(0x80 | 126)
            frame += [UInt8(length >> 8), UInt8(length & 0xFF)]
        } else {
            frame.append(0x80 | 127)
            for shift in stride(from: 56, through: 0, by: -8) { frame.append(UInt8((length >> shift) & 0xFF)) }
        }
        let mask = (0..<4).map { _ in UInt8.random(in: 0...255) }
        frame += mask
        for (index, byte) in data.enumerated() { frame.append(byte ^ mask[index % 4]) }
        try writeAll(frame)
    }

    private func receive() throws -> [String: Any] {
        var message = [UInt8]()
        while true {
            let head = try take(2)
            let opcode = head[0] & 0x0F
            let final = head[0] & 0x80 != 0
            var length = Int(head[1] & 0x7F)
            if length == 126 {
                let extra = try take(2)
                length = Int(extra[0]) << 8 | Int(extra[1])
            } else if length == 127 {
                length = try take(8).reduce(0) { $0 << 8 | Int($1) }
            }
            let payload = try take(length)
            if opcode == 8 { throw Failure("Rex closed the connection") }
            if opcode == 9 || opcode == 10 { continue }
            message += payload
            if final {
                guard let object = try JSONSerialization.jsonObject(with: Data(message)) as? [String: Any] else {
                    throw Failure("unreadable message from Rex")
                }
                return object
            }
        }
    }
}
