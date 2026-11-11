import Foundation

enum JumpHandler {
    static func handle(_ url: URL) {
        logLine("url \(url.absoluteString)")
        let pids = JumpRequest(url: url).candidatePids()
        guard !pids.isEmpty else {
            logLine("geen pid of tty, niets gedaan")
            return
        }
        let pidList = pids.sorted().map(String.init).joined(separator: " ")
        do {
            let client = try RexClient.connect()
            guard let pane = try client.findPane(matching: pids) else {
                logLine("pids \(pidList) niet gevonden in Rex")
                return
            }
            logLine("match pids \(pidList) -> \(pane.session) \(pane.window) \(pane.block)")
            try client.focus(pane)
            RexApp.activate()
            logLine("klaar")
        } catch let failure as Failure {
            logLine("mislukt: \(failure.message)")
        } catch {
            logLine("mislukt: \(error)")
        }
    }
}
