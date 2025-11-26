import SwifTeaUI

struct ErrorView: TUIView {
    typealias Body = Never

    let message: String
    let suggestion: String?
    let logPath: String?

    var body: Never { fatalError("ErrorView has no body") }

    func render() -> String {
        var lines = ["Error:", message]
        if let logPath {
            lines.append("Log: \(logPath)")
        }
        if let suggestion {
            lines.append("Next: \(suggestion)")
        }
        lines.append("Options: r retry · c cancel · b back")
        return lines.joined(separator: "\n")
    }
}
