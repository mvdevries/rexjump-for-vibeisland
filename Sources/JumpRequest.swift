import Foundation

struct JumpRequest {
    let pid: Int?
    let tty: String?

    init(url: URL) {
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        func value(_ name: String) -> String? {
            items.first { $0.name == name }?.value
        }
        pid = value("pid").flatMap { Int($0) }.flatMap { $0 > 0 ? $0 : nil }
        tty = value("tty").flatMap { $0.hasPrefix("/dev/tty") ? $0 : nil }
    }

    func candidatePids() -> Set<Int> {
        var pids = Set<Int>()
        if let pid { pids.insert(pid) }
        if let tty { pids.formUnion(ProcessLookup.pids(onTTY: tty)) }
        return pids
    }
}
