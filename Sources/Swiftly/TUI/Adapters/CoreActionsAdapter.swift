import Foundation
import SwiftlyCore

/// Bridges SwiftlyCore operations for TUI flows.
struct CoreActionsAdapter {
    let ctx: SwiftlyCoreContext
    var listOverride: (() async -> [ToolchainViewModel])?
    var switchOverride: ((String) async -> OperationSessionViewModel)?

    func listToolchains() async -> [ToolchainViewModel] {
        if let listOverride {
            return await listOverride()
        }
        do {
            let config = try await Config.load(ctx)
            let inUse = config.inUse
            let installed = config.listInstalledToolchains(selector: nil)
            return installed.map { version in
                ToolchainViewModel(
                    identifier: version.name,
                    version: version.name,
                    channel: version.isSnapshot() ? .snapshot : .stable,
                    location: nil,
                    isActive: inUse == version,
                    isInstalled: true,
                    metadata: .init(
                        installedAt: nil,
                        checksumVerified: nil,
                        sizeDescription: nil
                    )
                )
            }
        } catch {
            return []
        }
    }

    func activateToolchain(id: String) async -> OperationSessionViewModel {
        if let switchOverride {
            return await switchOverride(id)
        }
        do {
            var config = try await Config.load(ctx)
            let selector = try ToolchainSelector(parsing: id)
            guard let toolchain = config.listInstalledToolchains(selector: selector).max() else {
                return OperationSessionViewModel(
                    type: .switchToolchain,
                    targetIdentifier: id,
                    state: .failed(message: "No installed toolchains match \"\(id)\"", logPath: nil),
                    logPath: nil
                )
            }
            _ = try await Use.execute(ctx, toolchain, globalDefault: false, verbose: false, assumeYes: true, &config)
            return OperationSessionViewModel(
                type: .switchToolchain,
                targetIdentifier: toolchain.name,
                state: .succeeded(message: "Switched to \(toolchain.name)"),
                logPath: nil
            )
        } catch {
            return OperationSessionViewModel(
                type: .switchToolchain,
                targetIdentifier: id,
                state: .failed(message: "Switch failed: \(error)", logPath: nil),
                logPath: nil
            )
        }
    }

    func installToolchain(id: String) async -> OperationSessionViewModel {
        OperationSessionViewModel(
            type: .install,
            targetIdentifier: id,
            state: .failed(message: "Not implemented", logPath: nil),
            logPath: nil
        )
    }

    func uninstallToolchain(id: String) async -> OperationSessionViewModel {
        OperationSessionViewModel(
            type: .remove,
            targetIdentifier: id,
            state: .failed(message: "Not implemented", logPath: nil),
            logPath: nil
        )
    }

    func updateToolchain(id: String) async -> OperationSessionViewModel {
        OperationSessionViewModel(
            type: .update,
            targetIdentifier: id,
            state: .failed(message: "Not implemented", logPath: nil),
            logPath: nil
        )
    }
}
