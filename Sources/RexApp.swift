import Cocoa

enum RexApp {
    static let bundleIdentifier = "com.superlogical.rex"

    static func activate() {
        guard let url = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).first?.bundleURL else { return }
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        NSWorkspace.shared.openApplication(at: url, configuration: configuration)
    }
}
