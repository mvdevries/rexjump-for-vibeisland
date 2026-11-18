import Foundation

func logLine(_ text: String) {
    let path = NSHomeDirectory() + "/Library/Logs/rexjump-for-vibeisland.log"
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
