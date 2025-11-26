import Foundation
import SwiftlyCore
import SystemPackage

/// Bridges SwiftlyCore operations for TUI flows.
struct CoreActionsAdapter {
    let ctx: SwiftlyCoreContext
    var listOverride: (() async -> [ToolchainViewModel])?
    var switchOverride: ((String) async -> OperationSessionViewModel)?
    var installOverride: ((String) async -> OperationSessionViewModel)?
    var uninstallOverride: ((String) async -> OperationSessionViewModel)?
    var updateOverride: ((String) async -> OperationSessionViewModel)?
    var pendingOverride: (() async -> OperationSessionViewModel?)?

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
        if let installOverride {
            return await installOverride(id)
        }
        return await runOperation(type: .install, target: id) {
            var config = try await Config.load(ctx)
            let version = try await Install.determineToolchainVersion(ctx, version: id.isEmpty ? nil : id, config: &config)
            let progressFile = try await makeProgressFile(prefix: "install", identifier: version.identifier)
            _ = try await Install.execute(
                ctx,
                version: version,
                &config,
                useInstalledToolchain: false,
                verifySignature: true,
                verbose: false,
                assumeYes: true,
                progressFile: progressFile
            )
            return ("Installed \(version.identifier)", progressFile)
        }
    }

    func uninstallToolchain(id: String) async -> OperationSessionViewModel {
        if let uninstallOverride {
            return await uninstallOverride(id)
        }
        return await runOperation(type: .remove, target: id) {
            var config = try await Config.load(ctx)
            let selector = try ToolchainSelector(parsing: id)
            let matches = config.listInstalledToolchains(selector: selector)
            guard !matches.isEmpty else {
                throw SwiftlyError(message: "No installed toolchains match \"\(id)\"")
            }
            if let active = config.inUse, matches.contains(active) {
                throw SwiftlyError(message: "Cannot remove active toolchain \(active.name). Switch first.")
            }
            for toolchain in matches {
                try await Uninstall.execute(ctx, toolchain, &config, verbose: false)
            }
            return ("Uninstalled \(matches.count) toolchain(s)", nil)
        }
    }

    func updateToolchain(id: String) async -> OperationSessionViewModel {
        if let updateOverride {
            return await updateOverride(id)
        }
        return await runOperation(type: .update, target: id) {
            var config = try await Config.load(ctx)
            let current: ToolchainVersion
            if id.isEmpty {
                guard let inUse = config.inUse else {
                    throw SwiftlyError(message: "No toolchain in use to update. Provide an identifier.")
                }
                current = inUse
            } else {
                let selector = try ToolchainSelector(parsing: id)
                guard let found = config.listInstalledToolchains(selector: selector).max() else {
                    throw SwiftlyError(message: "No installed toolchains match \"\(id)\"")
                }
                current = found
            }

            let targetVersion = try await Install.determineToolchainVersion(ctx, version: id.isEmpty ? current.identifier : id, config: &config)
            if targetVersion == current {
                return ("Already up to date (\(current.identifier))", nil)
            }

            let progressFile = try await makeProgressFile(prefix: "update", identifier: targetVersion.identifier)
            _ = try await Install.execute(
                ctx,
                version: targetVersion,
                &config,
                useInstalledToolchain: config.inUse == current,
                verifySignature: true,
                verbose: false,
                assumeYes: true,
                progressFile: progressFile
            )
            try await Uninstall.execute(ctx, current, &config, verbose: false)
            return ("Updated \(current.identifier) → \(targetVersion.identifier)", progressFile)
        }
    }

    func loadPendingSession() async -> OperationSessionViewModel? {
        if let pendingOverride {
            return await pendingOverride()
        }
        let pendingPath = Swiftly.currentPlatform.swiftlyHomeDir(ctx) / "logs" / "tui-pending.json"
        guard let data = try? await fs.cat(atPath: pendingPath) else { return nil }
        guard let decoded = try? JSONDecoder().decode(PersistedSession.self, from: data) else { return nil }
        return decoded.toViewModel()
    }
}

private extension CoreActionsAdapter {
    func makeProgressFile(prefix: String, identifier: String) async throws -> FilePath {
        let logDir = Swiftly.currentPlatform.swiftlyHomeDir(ctx) / "logs"
        try? await fs.mkdir(.parents, atPath: logDir)
        let safeId = identifier.replacingOccurrences(of: "/", with: "-")
        let path = logDir / "tui-\(prefix)-\(safeId).jsonl"
        try await fs.create(file: path, contents: nil)
        return path
    }

    func runOperation(
        type: OperationSessionViewModel.OperationType,
        target: String?,
        work: () async throws -> (message: String, logPath: FilePath?)
    ) async -> OperationSessionViewModel {
        do {
            let (message, logPath) = try await work()
            return OperationSessionViewModel(
                type: type,
                targetIdentifier: target,
                state: .succeeded(message: message),
                logPath: logPath?.string
            )
        } catch {
            return OperationSessionViewModel(
                type: type,
                targetIdentifier: target,
                state: .failed(message: "\(typeLabel(type)) failed: \(error)", logPath: nil),
                logPath: nil
            )
        }
    }

    func typeLabel(_ type: OperationSessionViewModel.OperationType) -> String {
        switch type {
        case .list: return "List"
        case .detail: return "Detail"
        case .switchToolchain: return "Switch"
        case .install: return "Install"
        case .update: return "Update"
        case .remove: return "Remove"
        }
    }
}

private struct PersistedSession: Codable {
    let type: String
    let target: String?
    let state: String
    let message: String?
    let logPath: String?

    func toViewModel() -> OperationSessionViewModel? {
        let opType: OperationSessionViewModel.OperationType?
        switch type {
        case "install": opType = .install
        case "update": opType = .update
        case "remove": opType = .remove
        case "switch": opType = .switchToolchain
        default: opType = nil
        }
        guard let opType else { return nil }

        let opState: OperationSessionViewModel.State
        switch state {
        case "running", "pending":
            opState = .pending
        case "failed":
            opState = .failed(message: message ?? "Failed", logPath: logPath)
        case "cancelled":
            opState = .cancelled(message: message, logPath: logPath)
        case "succeeded":
            opState = .succeeded(message: message ?? "Done")
        default:
            opState = .pending
        }

        return OperationSessionViewModel(
            type: opType,
            targetIdentifier: target,
            state: opState,
            logPath: logPath
        )
    }
}
