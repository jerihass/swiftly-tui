import Foundation
import SwiftlyCore

/// Bridges SwiftlyCore operations for TUI flows. Placeholder implementations to be replaced with real wiring.
struct CoreActionsAdapter {
    let ctx: SwiftlyCoreContext

    func listToolchains() async -> [ToolchainSummary] {
        do {
            let config = try await Config.load(ctx)
            let inUse = config.inUse
            let installed = config.listInstalledToolchains(selector: nil)
            return installed.map { version in
                ToolchainSummary(
                    id: version.name,
                    name: version.name,
                    version: version.name,
                    channel: version.isSnapshot() ? "snapshot" : "release",
                    status: inUse == version ? "active" : "installed"
                )
            }
        } catch {
            return []
        }
    }

    func activateToolchain(id: String) async -> OperationOutcome {
        do {
            var config = try await Config.load(ctx)
            let selector = try ToolchainSelector(parsing: id)
            guard let toolchain = config.listInstalledToolchains(selector: selector).max() else {
                return OperationOutcome(action: "switch", targetToolchainId: id, status: .failed, message: "No match")
            }
            _ = try await Use.execute(ctx, toolchain, globalDefault: false, verbose: false, assumeYes: true, &config)
            return OperationOutcome(action: "switch", targetToolchainId: toolchain.name, status: .success, message: "Switched")
        } catch {
            return OperationOutcome(action: "switch", targetToolchainId: id, status: .failed, message: "\(error)")
        }
    }

    func installToolchain(id: String) async -> OperationOutcome {
        return OperationOutcome(action: "install", targetToolchainId: id, status: .failed, message: "Not implemented")
    }

    func uninstallToolchain(id: String) async -> OperationOutcome {
        return OperationOutcome(action: "uninstall", targetToolchainId: id, status: .failed, message: "Not implemented")
    }

    func updateToolchain(id: String) async -> OperationOutcome {
        return OperationOutcome(action: "update", targetToolchainId: id, status: .failed, message: "Not implemented")
    }
}
