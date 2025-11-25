import Foundation

/// Suggests valid toolchains when input is invalid. Placeholder implementation.
enum ValidationAdapter {
    static func suggest(valid: [ToolchainViewModel], entered: String) -> [ToolchainViewModel] {
        valid.filter { $0.identifier.contains(entered) || $0.version.contains(entered) }
    }
}
