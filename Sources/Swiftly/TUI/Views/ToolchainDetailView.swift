import SwifTeaUI

struct ToolchainDetailView: TUIView {
    typealias Body = Never

    let summary: ToolchainSummary
    let location: String?
    let size: String?
    let lastResult: OperationOutcome?

    var body: Never { fatalError("ToolchainDetailView has no body") }

    func render() -> String {
        var lines: [String] = []
        lines.append("Toolchain: \(summary.name) \(summary.version) [\(summary.channel)]")
        lines.append("Status: \(summary.status)")
        if let location { lines.append("Location: \(location)") }
        if let size { lines.append("Size: \(size)") }
        if let lastResult {
            lines.append("Last: \(lastResult.action) -> \(lastResult.status) (\(lastResult.message))")
        }
        return lines.joined(separator: "\n")
    }
}
