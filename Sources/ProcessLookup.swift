import Darwin

enum ProcessLookup {
    static func pids(onTTY path: String) -> [Int] {
        guard let device = deviceNumber(of: path) else { return [] }
        return pids(onDevice: device)
    }

    private static func deviceNumber(of path: String) -> UInt32? {
        var info = stat()
        guard stat(path, &info) == 0 else { return nil }
        return UInt32(info.st_rdev)
    }

    private static func pids(onDevice device: UInt32) -> [Int] {
        let filter = UInt32(PROC_TTY_ONLY)
        let pidSize = MemoryLayout<pid_t>.size

        let bytesNeeded = Int(proc_listpids(filter, device, nil, 0))
        guard bytesNeeded > 0 else { return [] }

        let capacity = bytesNeeded / pidSize + 16
        var pids = [pid_t](repeating: 0, count: capacity)
        let bytesWritten = Int(proc_listpids(filter, device, &pids, Int32(capacity * pidSize)))
        guard bytesWritten > 0 else { return [] }

        let count = bytesWritten / pidSize
        return pids.prefix(count).filter { $0 > 0 }.map { Int($0) }
    }
}
