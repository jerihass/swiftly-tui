import SwifTeaUI

struct ToolchainListView: TUIView {
    typealias Body = Never

    let toolchains: [ToolchainSummary]

    var body: Never { fatalError("ToolchainListView has no body") }

    func render() -> String {
        guard !toolchains.isEmpty else {
            return "No toolchains found."
        }
        let lines = toolchains.map { summary in
            "\(summary.name) \(summary.version) [\(summary.channel)] - \(summary.status)"
        }
        return lines.joined(separator: "\n")
    }
}
