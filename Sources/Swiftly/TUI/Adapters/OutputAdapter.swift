import SwiftlyCore

/// Ensures stdout/stderr separation and structured error messaging.
enum OutputAdapter {
    static func info(_ ctx: SwiftlyCoreContext, _ message: String) async {
        await ctx.message(message)
    }

    static func error(_ ctx: SwiftlyCoreContext, _ message: String) async {
        await ctx.printError("ERROR: \(message)")
    }

    static func renderInfo(_ message: String) -> String { message }

    static func renderError(_ message: String) -> String { "ERROR: \(message)" }
}
