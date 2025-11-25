import SwifTeaUI

struct ToolchainDetailView: TUIView {
    typealias Body = Never

    let summary: ToolchainViewModel
    let lastResult: OperationSessionViewModel?

    var body: Never { fatalError("ToolchainDetailView has no body") }

    func render() -> String {
        var lines: [String] = []
        lines.append("Toolchain: \(summary.identifier) \(summary.version) [\(summary.channel.rawValue)]")
        lines.append("Status: \(summary.isActive ? "active" : "installed")")
        if let location = summary.location { lines.append("Location: \(location)") }
        if let meta = summary.metadata {
            if let size = meta.sizeDescription { lines.append("Size: \(size)") }
            if let verified = meta.checksumVerified {
                lines.append("Verified: \(verified ? "yes" : "unknown")")
            }
        }
        if let lastResult {
            switch lastResult.state {
            case .succeeded(let message):
                lines.append("Last: \(message)")
            case .failed(let message, let logPath):
                lines.append("Last: failed - \(message)")
                if let logPath { lines.append("Log: \(logPath)") }
            case .cancelled(let message, let logPath):
                lines.append("Last: cancelled - \(message ?? "cancelled")")
                if let logPath { lines.append("Log: \(logPath)") }
            case .running(let progress, let msg):
                lines.append("Last: running \(progress)% \(msg ?? "")")
            case .pending:
                lines.append("Last: pending")
            }
        }
        return lines.joined(separator: "\n")
    }
}
