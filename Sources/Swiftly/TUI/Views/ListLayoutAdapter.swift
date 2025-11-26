import Foundation

/// Placeholder for sorting/filtering and small terminal handling.
enum ListLayoutAdapter {
    static func sort(_ toolchains: [ToolchainViewModel]) -> [ToolchainViewModel] {
        toolchains.sorted { lhs, rhs in
            if lhs.isActive == rhs.isActive {
                return lhs.identifier < rhs.identifier
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

    static func rowSpacing(for count: Int) -> Int {
        count > 15 ? 0 : 1
    }

    static func emptyStateMessage() -> String {
        "No toolchains found. Choose Install to add one."
    }
}
