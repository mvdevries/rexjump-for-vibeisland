import Foundation

struct PaneLocation {
    let session: String
    let window: String
    let block: String
}

final class RexClient {
    private let connection: RexConnection

    static func connect() throws -> RexClient {
        let socketPath = NSHomeDirectory() + "/Library/Application Support/rex/server.sock"
        return try RexClient(connection: RexConnection(path: socketPath))
    }

    private init(connection: RexConnection) throws {
        self.connection = connection
        _ = try connection.call("session.attach_all", ["event_scope": "session"])
    }

    func findPane(matching pids: Set<Int>) throws -> PaneLocation? {
        for sessionID in try sessionIDs() {
            for pane in placedPanes(in: sessionID) {
                guard let process = processInfo(of: pane) else { continue }
                if PaneMatcher.matches(process: process, pids: pids) { return pane }
            }
        }
        return nil
    }

    func focus(_ pane: PaneLocation) throws {
        try focusBlock(of: pane)
        try showInApp(pane)
    }

    private func focusBlock(of pane: PaneLocation) throws {
        _ = try connection.call("session.focus_block", [
            "session_id": pane.session,
            "block_id": pane.block,
        ])
    }

    private func showInApp(_ pane: PaneLocation) throws {
        guard let clientID = try appClientID() else { return }
        _ = try connection.call("client.perform", [
            "client_id": clientID,
            "action": "session.select",
            "args": ["session_id": pane.session, "window_id": pane.window],
        ])
    }

    private func sessionIDs() throws -> [String] {
        let reply = try connection.call("session.list")
        let sessions = reply["sessions"] as? [[String: Any]] ?? []
        return sessions.compactMap { $0["session_id"] as? String }
    }

    private func placedPanes(in sessionID: String) -> [PaneLocation] {
        guard let reply = try? connection.call("session.list_blocks", ["session_id": sessionID]),
              let blocks = reply["blocks"] as? [[String: Any]] else { return [] }
        return blocks.compactMap { block in
            guard block["placement"] as? String == "placed",
                  let blockID = block["block_id"] as? String,
                  let windowID = block["window_id"] as? String else { return nil }
            return PaneLocation(session: sessionID, window: windowID, block: blockID)
        }
    }

    private func processInfo(of pane: PaneLocation) -> [String: Any]? {
        try? connection.call("block.method", [
            "session_id": pane.session,
            "block_id": pane.block,
            "method": "process",
        ])
    }

    private func appClientID() throws -> String? {
        let reply = try connection.call("client.list")
        let clients = reply["clients"] as? [[String: Any]] ?? []
        let app = clients.first { client in
            (client["info"] as? [String: Any])?["kind"] as? String == "app"
        }
        return app?["client_id"] as? String
    }
}
