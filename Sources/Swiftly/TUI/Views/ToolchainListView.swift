import SwifTeaUI

struct ToolchainListView: TUIView {
    typealias Body = Never

    let toolchains: [ToolchainViewModel]

    var body: Never { fatalError("ToolchainListView has no body") }

    func render() -> String {
        guard !toolchains.isEmpty else {
            return "No toolchains found."
        }
        let lines = toolchains.map { summary in
            let activeMark = summary.isActive ? "*" : " "
            return "[\(activeMark)] \(summary.identifier) \(summary.version) [\(summary.channel.rawValue)]"
        }
        return lines.joined(separator: "\n")
    }
}
