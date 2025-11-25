import ArgumentParser
import SwifTeaUI
import SwiftlyCore

struct TUICommand: SwiftlyCommand {
    static let configuration = CommandConfiguration(
        commandName: "tui",
        abstract: "Launch the swiftly text UI for core actions."
    )

    @OptionGroup
    var global: GlobalOptions

    mutating func run() async throws {
        try await self.run(Swiftly.createDefaultContext())
    }

    mutating func run(_ ctx: SwiftlyCoreContext) async throws {
        _ = global
        let app = SwiftlyTUIApplication(ctx: ctx)
        SwifTea.brew(app)
    }
}
