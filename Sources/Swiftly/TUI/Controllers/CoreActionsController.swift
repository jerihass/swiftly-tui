import SwiftlyCore

/// Thin controller that routes TUI intents to CoreActionsAdapter.
struct CoreActionsController {
    let ctx: SwiftlyCoreContext
    let adapterFactory: @Sendable (SwiftlyCoreContext) -> CoreActionsAdapter

    init(ctx: SwiftlyCoreContext, adapterFactory: @escaping @Sendable (SwiftlyCoreContext) -> CoreActionsAdapter) {
        self.ctx = ctx
        self.adapterFactory = adapterFactory
    }

    func list() async -> [ToolchainViewModel] {
        await adapterFactory(ctx).listToolchains()
    }

    func listAvailable() async -> AvailableToolchainsResult {
        await adapterFactory(ctx).listAvailableToolchains()
    }

    func switchToolchain(id: String) async -> OperationSessionViewModel {
        await adapterFactory(ctx).activateToolchain(id: id)
    }

    func install(id: String, onProgressLog: @Sendable (String) -> Void = { _ in }) async -> OperationSessionViewModel {
        await adapterFactory(ctx).installToolchain(id: id, onProgressLog: onProgressLog)
    }

    func update(id: String, onProgressLog: @Sendable (String) -> Void = { _ in }) async -> OperationSessionViewModel {
        await adapterFactory(ctx).updateToolchain(id: id, onProgressLog: onProgressLog)
    }

    func remove(id: String) async -> OperationSessionViewModel {
        await adapterFactory(ctx).uninstallToolchain(id: id)
    }

    func loadPendingSession() async -> OperationSessionViewModel? {
        await adapterFactory(ctx).loadPendingSession()
    }
}
