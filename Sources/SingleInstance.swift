import Cocoa

enum SingleInstance {
    static func isDuplicate() -> Bool {
        let own = ProcessInfo.processInfo.processIdentifier
        guard let identifier = Bundle.main.bundleIdentifier else { return false }
        return NSRunningApplication.runningApplications(withBundleIdentifier: identifier)
            .contains { $0.processIdentifier < own }
    }
}
