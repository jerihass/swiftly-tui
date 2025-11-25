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
        // Placeholder launch; will be replaced with SwifTeaUI host in US1.
        _ = global
        _ = ctx
    }
}
