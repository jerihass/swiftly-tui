import Foundation

/// Shared layout helpers for list/detail rendering and density control.
enum ListLayoutAdapter {
    /// Column layout tuned for 80-col terminals.
    struct ColumnLayout {
        let columnSpacing: Int
        let idMinWidth: Int
        let channelMinWidth: Int
        let statusMinWidth: Int
    }

    /// Guidance message shown when no toolchains exist.
    struct EmptyState {
        let title: String
        let guidance: String

        var lines: [String] { [title, guidance] }
        var combined: String { lines.joined(separator: " ") }
    }

    static func sort(_ toolchains: [ToolchainViewModel]) -> [ToolchainViewModel] {
        toolchains.sorted { lhs, rhs in
            if lhs.isActive == rhs.isActive {
                return lhs.identifier > rhs.identifier // newest-ish (desc) when active status ties
            } else {
                return lhs.isActive && !rhs.isActive
            }
        }
    }

    static func filter(_ toolchains: [ToolchainViewModel], query: String?) -> [ToolchainViewModel] {
        guard let query, !query.isEmpty else { return toolchains }
        let lowered = query.lowercased()
        return toolchains.filter {
            $0.identifier.lowercased().contains(lowered) || $0.version.lowercased().contains(lowered)
        }
    }

    /// Row spacing becomes compact for dense lists or narrow terminals.
    static func rowSpacing(for count: Int, terminalWidth: Int = 80) -> Int {
        (count >= 20 || terminalWidth <= 80) ? 0 : 1
    }

    /// Column layout tuned to keep identifiers/channels/status aligned.
    static func columnLayout(for terminalWidth: Int = 80) -> ColumnLayout {
        // Reserve space for numbering and separators; give most flex to identifier.
        if terminalWidth <= 80 {
            return ColumnLayout(columnSpacing: 1, idMinWidth: 16, channelMinWidth: 8, statusMinWidth: 8)
        } else {
            return ColumnLayout(columnSpacing: 2, idMinWidth: 20, channelMinWidth: 10, statusMinWidth: 10)
        }
    }

    /// Truncate long identifiers to avoid overflow while preserving uniqueness.
    static func truncateIdentifier(_ identifier: String, maxLength: Int = 32) -> String {
        guard identifier.count > maxLength else { return identifier }
        let prefix = identifier.prefix(maxLength - 3)
        return "\(prefix)…"
    }

    static func emptyState() -> EmptyState {
        EmptyState(
            title: "No toolchains installed.",
            guidance: "Use Install (2) to add one."
        )
    }
}
