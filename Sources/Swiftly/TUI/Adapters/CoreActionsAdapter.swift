import Foundation
import SwiftlyCore

/// Bridges SwiftlyCore operations for TUI flows. Placeholder implementations to be replaced with real wiring.
struct CoreActionsAdapter {
    let ctx: SwiftlyCoreContext

    func listToolchains() async throws -> [ToolchainSummary] {
        // TODO: integrate with existing list logic from CLI commands.
        return []
    }

    func activateToolchain(id: String) async throws -> OperationOutcome {
        // TODO: integrate with use/switch flow.
        return OperationOutcome(action: "switch", targetToolchainId: id, status: .failed, message: "Not implemented")
    }

    func installToolchain(id: String) async throws -> OperationOutcome {
        // TODO: integrate with install flow.
        return OperationOutcome(action: "install", targetToolchainId: id, status: .failed, message: "Not implemented")
    }

    func uninstallToolchain(id: String) async throws -> OperationOutcome {
        // TODO: integrate with uninstall flow.
        return OperationOutcome(action: "uninstall", targetToolchainId: id, status: .failed, message: "Not implemented")
    }

    func updateToolchain(id: String) async throws -> OperationOutcome {
        // TODO: integrate with update flow.
        return OperationOutcome(action: "update", targetToolchainId: id, status: .failed, message: "Not implemented")
    }
}
