import ArgumentParser
import SwiftlyCore

struct TUICommand: SwiftlyCommand {
    static let configuration = CommandConfiguration(
        commandName: "tui",
        abstract: "Launch the swiftly text UI for core actions."
    )

    @OptionGroup
    var global: GlobalOptions

    mutating func run(_ ctx: SwiftlyCoreContext) async throws {
        _ = global
        // TODO: integrate SwifTeaUI host and render RootMenuView with CoreActionsController.
        // Placeholder to indicate command is reachable.
        ctx.message("TUI coming soon. Run swiftly tui after implementation.")
    }
}
