import Foundation

/// Placeholder for sorting/filtering and small terminal handling.
enum ListLayoutAdapter {
    static func sort(_ toolchains: [ToolchainSummary]) -> [ToolchainSummary] {
        toolchains.sorted { $0.name < $1.name }
    }

    static func filter(_ toolchains: [ToolchainSummary], query: String?) -> [ToolchainSummary] {
        guard let query, !query.isEmpty else { return toolchains }
        return toolchains.filter { $0.name.contains(query) || $0.version.contains(query) }
    }
}
