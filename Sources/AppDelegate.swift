import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let duplicate = SingleInstance.isDuplicate()

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard duplicate else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { NSApp.terminate(nil) }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls { JumpHandler.handle(url) }
        if duplicate { NSApp.terminate(nil) }
    }
}
