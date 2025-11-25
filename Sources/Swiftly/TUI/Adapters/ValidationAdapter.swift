import Foundation

/// Suggests valid toolchains when input is invalid. Placeholder implementation.
enum ValidationAdapter {
    static func suggest(valid: [ToolchainSummary], entered: String) -> [ToolchainSummary] {
        valid.filter { $0.name.contains(entered) || $0.version.contains(entered) }
    }
}
