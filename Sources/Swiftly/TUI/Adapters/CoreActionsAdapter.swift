import Foundation
import SwiftlyCore

/// Bridges SwiftlyCore operations for TUI flows.
struct CoreActionsAdapter {
    let ctx: SwiftlyCoreContext

    func listToolchains() async throws -> [ToolchainSummary] {
        try await SwiftlyCore.ToolchainService.listToolchains(ctx: ctx)
    }

    func activateToolchain(id: String) async throws -> OperationOutcome {
        try await SwiftlyCore.ToolchainService.activateToolchain(ctx: ctx, id: id)
    }

    func installToolchain(id: String) async throws -> OperationOutcome {
        try await SwiftlyCore.ToolchainService.installToolchain(ctx: ctx, id: id)
    }

    func uninstallToolchain(id: String) async throws -> OperationOutcome {
        try await SwiftlyCore.ToolchainService.uninstallToolchain(ctx: ctx, id: id)
    }

    func updateToolchain(id: String) async throws -> OperationOutcome {
        try await SwiftlyCore.ToolchainService.updateToolchain(ctx: ctx, id: id)
    }
}
