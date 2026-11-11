import Cocoa
import Darwin

struct Failure: Error {
    let message: String
    init(_ message: String) { self.message = message }
}

func logLine(_ text: String) {
    let path = NSHomeDirectory() + "/Library/Logs/rex-vibe-island-jump.log"
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let line = formatter.string(from: Date()) + " " + text + "\n"
    if let handle = FileHandle(forWritingAtPath: path) {
        handle.seekToEndOfFile()
        handle.write(Data(line.utf8))
        try? handle.close()
    } else {
        try? line.write(toFile: path, atomically: false, encoding: .utf8)
    }
}

final class Control {
    private let fd: Int32
    private var buffer = [UInt8]()
    private var counter = 0

    init(path: String) throws {
        fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { throw Failure("socket aanmaken mislukt") }
        var address = sockaddr_un()
        address.sun_family = sa_family_t(AF_UNIX)
        let bytes = Array(path.utf8CString)
        guard bytes.count <= MemoryLayout.size(ofValue: address.sun_path) else {
            close(fd)
            throw Failure("socketpad te lang")
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
            throw Failure("verbinden met Rex mislukt")
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

    private func writeAll(_ data: [UInt8]) throws {
        var sent = 0
        while sent < data.count {
            let count = data[sent...].withUnsafeBytes { write(fd, $0.baseAddress, $0.count) }
            guard count > 0 else { throw Failure("schrijven naar Rex mislukt") }
            sent += count
        }
    }

    private func take(_ count: Int) throws -> [UInt8] {
        while buffer.count < count {
            var chunk = [UInt8](repeating: 0, count: 65536)
            let received = read(fd, &chunk, chunk.count)
            guard received > 0 else { throw Failure("verbinding met Rex gesloten") }
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
            guard head.count < 8192 else { throw Failure("onverwacht antwoord van Rex") }
        }
        let status = String(decoding: head, as: UTF8.self).components(separatedBy: "\r\n").first ?? ""
        guard status.contains(" 101 ") else { throw Failure("handshake geweigerd: \(status)") }
    }

    private func hello() throws {
        try send(["type": "hello", "api_revision": 10, "client": ["kind": "other", "name": "rexjump", "version": "1"]])
        let welcome = try receive()
        guard welcome["type"] as? String == "welcome" else { throw Failure("geen welcome van Rex") }
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
            if opcode == 8 { throw Failure("Rex sloot de verbinding") }
            if opcode == 9 || opcode == 10 { continue }
            message += payload
            if final {
                guard let object = try JSONSerialization.jsonObject(with: Data(message)) as? [String: Any] else {
                    throw Failure("onleesbaar bericht van Rex")
                }
                return object
            }
        }
    }

    func call(_ method: String, _ payload: [String: Any] = [:]) throws -> [String: Any] {
        counter += 1
        let id = String(counter)
        try send(["type": "request", "id": id, "method": method, "payload": payload])
        while true {
            let message = try receive()
            guard message["type"] as? String == "response", message["id"] as? String == id else { continue }
            if let error = message["error"] as? [String: Any] {
                throw Failure("\(method): \(error["message"] as? String ?? "onbekende fout")")
            }
            return message["payload"] as? [String: Any] ?? [:]
        }
    }
}

func processes(on tty: String) -> [Int] {
    var info = stat()
    guard stat(tty, &info) == 0 else { return [] }
    let device = UInt32(info.st_rdev)
    let size = proc_listpids(UInt32(PROC_TTY_ONLY), device, nil, 0)
    guard size > 0 else { return [] }
    let stride = MemoryLayout<pid_t>.size
    var pids = [pid_t](repeating: 0, count: Int(size) / stride + 16)
    let written = proc_listpids(UInt32(PROC_TTY_ONLY), device, &pids, Int32(pids.count * stride))
    guard written > 0 else { return [] }
    return pids.prefix(Int(written) / stride).filter { $0 > 0 }.map { Int($0) }
}

func matches(_ process: [String: Any], _ pids: Set<Int>) -> Bool {
    var found = [Int]()
    for key in ["foreground", "child"] {
        if let entry = process[key] as? [String: Any], let pid = entry["pid"] as? Int { found.append(pid) }
    }
    if let ancestors = process["ancestors"] as? [[String: Any]] {
        found += ancestors.compactMap { $0["pid"] as? Int }
    }
    return found.contains { pids.contains($0) }
}

func activateRex() {
    guard let url = NSRunningApplication.runningApplications(withBundleIdentifier: "com.superlogical.rex").first?.bundleURL else { return }
    let configuration = NSWorkspace.OpenConfiguration()
    configuration.activates = true
    NSWorkspace.shared.openApplication(at: url, configuration: configuration)
}

func focus(_ url: URL) {
    logLine("url \(url.absoluteString)")
    let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
    func value(_ name: String) -> String? { items.first { $0.name == name }?.value }

    var pids = Set<Int>()
    if let raw = value("pid"), let pid = Int(raw), pid > 0 { pids.insert(pid) }
    if let tty = value("tty"), tty.hasPrefix("/dev/tty") { pids.formUnion(processes(on: tty)) }
    guard !pids.isEmpty else {
        logLine("geen pid of tty, niets gedaan")
        return
    }

    do {
        let control = try Control(path: NSHomeDirectory() + "/Library/Application Support/rex/server.sock")
        _ = try control.call("session.attach_all", ["event_scope": "session"])
        let sessions = try control.call("session.list")["sessions"] as? [[String: Any]] ?? []
        var match: (session: String, window: String, block: String)?
        search: for session in sessions {
            guard let sessionID = session["session_id"] as? String,
                  let listing = try? control.call("session.list_blocks", ["session_id": sessionID]),
                  let blocks = listing["blocks"] as? [[String: Any]] else { continue }
            for block in blocks where block["placement"] as? String == "placed" {
                guard let blockID = block["block_id"] as? String, let windowID = block["window_id"] as? String,
                      let process = try? control.call("block.method", ["session_id": sessionID, "block_id": blockID, "method": "process"])
                else { continue }
                if matches(process, pids) {
                    match = (sessionID, windowID, blockID)
                    break search
                }
            }
        }
        let sortedPids = pids.sorted().map(String.init).joined(separator: " ")
        guard let target = match else {
            logLine("pids \(sortedPids) niet gevonden in Rex")
            return
        }
        logLine("match pids \(sortedPids) -> \(target.session) \(target.window) \(target.block)")

        _ = try control.call("session.focus_block", ["session_id": target.session, "block_id": target.block])
        let clients = try control.call("client.list")["clients"] as? [[String: Any]] ?? []
        let app = clients.first { ($0["info"] as? [String: Any])?["kind"] as? String == "app" }
        if let clientID = app?["client_id"] as? String {
            _ = try control.call("client.perform", [
                "client_id": clientID,
                "action": "session.select",
                "args": ["session_id": target.session, "window_id": target.window],
            ])
        }
        activateRex()
        logLine("klaar")
    } catch let failure as Failure {
        logLine("mislukt: \(failure.message)")
    } catch {
        logLine("mislukt: \(error)")
    }
}

final class Delegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls { focus(url) }
    }
}

let app = NSApplication.shared
let delegate = Delegate()
app.delegate = delegate
app.setActivationPolicy(.prohibited)
app.run()
