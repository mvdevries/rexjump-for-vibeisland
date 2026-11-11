enum PaneMatcher {
    static func matches(process: [String: Any], pids: Set<Int>) -> Bool {
        var found = [Int]()
        for key in ["foreground", "child"] {
            if let entry = process[key] as? [String: Any], let pid = entry["pid"] as? Int {
                found.append(pid)
            }
        }
        if let ancestors = process["ancestors"] as? [[String: Any]] {
            found += ancestors.compactMap { $0["pid"] as? Int }
        }
        return found.contains { pids.contains($0) }
    }
}
