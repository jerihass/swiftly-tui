import Foundation

enum LayoutSizing {
    static let contentWidth: Int = 72
    static let baseHeight: Int = 18
    // Account for filter line + table header/divider; the remainder is usable data rows.
    static let listViewport: Int = max(8, baseHeight - 7) // 18 -> ~9 data rows

    static func minHeight(for screen: SwiftlyTUIApplication.Model.Screen) -> Int {
        // Keep a consistent baseline height across all screens; taller views can extend naturally.
        return baseHeight
    }
}

/// Returns the filtered toolchains based on the current filter string.
func filteredToolchains(_ model: SwiftlyTUIApplication.Model) -> [ToolchainViewModel] {
    guard !model.filter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        return model.toolchains
    }
    let query = model.filter.lowercased()
    return model.toolchains.filter { tc in
        tc.identifier.lowercased().contains(query) || tc.channel.rawValue.lowercased().contains(query)
    }
}

/// Returns the filtered available toolchains based on the current filter string.
func filteredAvailableToolchains(_ model: SwiftlyTUIApplication.Model) -> [ToolchainViewModel] {
    guard !model.filter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        return model.availableToolchains
    }
    let query = model.filter.lowercased()
    return model.availableToolchains.filter { tc in
        tc.identifier.lowercased().contains(query) || tc.channel.rawValue.lowercased().contains(query)
    }
}

/// Returns the filtered toolchains for the active list-like screen.
func currentFilteredToolchains(_ model: SwiftlyTUIApplication.Model) -> [ToolchainViewModel] {
    if case .installList = model.screen {
        return filteredAvailableToolchains(model)
    }
    return filteredToolchains(model)
}

/// Keeps the focused row within the visible viewport.
func adjustedListOffset(focused: Int, total: Int, viewport: Int, currentOffset: Int) -> Int {
    // Treat one line as consumed by header/divider for ScrollView height.
    let visibleRows = max(1, viewport - 2)
    guard total > visibleRows else { return 0 }
    let maxOffset = max(0, total - visibleRows)
    var offset = min(currentOffset, maxOffset)
    if focused < offset {
        offset = focused
    } else if focused >= offset + visibleRows {
        offset = focused - visibleRows + 1
    }
    return min(maxOffset, max(0, offset))
}
