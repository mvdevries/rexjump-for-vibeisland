import Foundation

enum JumpHandler {
    static func handle(_ url: URL) {
        logLine("url \(url.absoluteString)")
        let pids = JumpRequest(url: url).candidatePids()
        guard !pids.isEmpty else {
            logLine("no pid or tty, did nothing")
            return
        }
        let pidList = pids.sorted().map(String.init).joined(separator: " ")
        do {
            let client = try RexClient.connect()
            guard let pane = try client.findPane(matching: pids) else {
                logLine("pids \(pidList) not found in Rex")
                return
            }
            logLine("match pids \(pidList) -> \(pane.session) \(pane.window) \(pane.block)")
            try client.focus(pane)
            RexApp.activate()
            logLine("done")
        } catch let failure as Failure {
            logLine("failed: \(failure.message)")
        } catch {
            logLine("failed: \(error)")
        }
    }
}
