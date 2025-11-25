import SwifTeaUI

struct ErrorView: TUIView {
    typealias Body = Never

    let message: String
    let suggestion: String?

    var body: Never { fatalError("ErrorView has no body") }

    func render() -> String {
        var lines = ["Error:", message]
        if let suggestion {
            lines.append("Next: \(suggestion)")
        }
        return lines.joined(separator: "\n")
    }
}
