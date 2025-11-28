import SwiftlyCore

/// Output handler used by the TUI to swallow Swiftly log messages that would otherwise wake the terminal.
actor TUIApplicationOutputHandler: OutputHandler {
    func handleOutputLine(_ string: String) async {
        _ = string
    }
}
