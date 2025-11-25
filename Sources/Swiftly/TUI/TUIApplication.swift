import Foundation
import SwifTeaUI
import SwiftlyCore

struct SwiftlyTUIApplication: TUIScene {
    struct Model {
        enum Screen {
            case menu
            case list
            case input(ActionType)
            case progress(String)
            case result(String)
        }

        var screen: Screen = .menu
        var toolchains: [ToolchainSummary] = []
        var message: String = "Use numbers to choose an action."
        var input: String = ""
    }

    enum ActionType: String {
        case list = "List"
        case switchActive = "Switch"
        case install = "Install"
        case uninstall = "Uninstall"
        case update = "Update"
        case exit = "Exit"
    }

    enum Action {
        case showMenu
        case start(ActionType)
        case inputChar(Character)
        case backspace
        case submit
        case cancelInput
        case loadList
        case listLoaded([ToolchainSummary])
        case runSwitch(String)
        case operationResult(String)
        case exit
    }

    var model: Model = Model()
    let ctx: SwiftlyCoreContext

    init(ctx: SwiftlyCoreContext) {
        self.ctx = ctx
    }

    func view(model: Model) -> some TUIView {
        RootTUIView(model: model)
    }

    mutating func update(action: Action) {
        switch action {
        case .showMenu:
            model.screen = .menu
            model.message = "Use numbers to choose an action."
            model.input = ""
        case .start(let type):
            switch type {
            case .list:
                model.screen = .progress("Loading toolchains...")
                let ctx = self.ctx
                Task.detached {
                    let list = await Self.loadInstalled(ctx: ctx)
                    SwifTea.dispatch(Action.listLoaded(list))
                }
            case .switchActive:
                model.screen = .input(.switchActive)
                model.input = ""
                model.message = "Enter toolchain to switch to:"
            case .install, .uninstall, .update:
                model.screen = .input(type)
                model.input = ""
                model.message = "Enter toolchain identifier for \(type.rawValue.lowercased()):"
            case .exit:
                break
            }
        case .inputChar(let ch):
            model.input.append(ch)
        case .backspace:
            if !model.input.isEmpty { model.input.removeLast() }
        case .submit:
            switch model.screen {
            case .input(let type):
                let value = model.input.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !value.isEmpty else {
                    model.message = "Input cannot be empty."
                    return
                }
                switch type {
                case .switchActive:
                    model.screen = .progress("Switching to \(value)...")
                    let ctx = self.ctx
                    Task.detached {
                        let result = await Self.performSwitch(ctx: ctx, to: value)
                        SwifTea.dispatch(Action.operationResult(result))
                    }
                case .install:
                    model.screen = .progress("Install \(value) not yet implemented.")
                    SwifTea.dispatch(Action.operationResult("Install \(value): not implemented yet."))
                case .uninstall:
                    model.screen = .progress("Uninstall \(value) not yet implemented.")
                    SwifTea.dispatch(Action.operationResult("Uninstall \(value): not implemented yet."))
                case .update:
                    model.screen = .progress("Update \(value) not yet implemented.")
                    SwifTea.dispatch(Action.operationResult("Update \(value): not implemented yet."))
                case .list, .exit:
                    break
                }
            default:
                break
            }
        case .cancelInput:
            model.screen = .menu
            model.input = ""
            model.message = "Use numbers to choose an action."
        case .loadList:
            model.screen = .progress("Loading toolchains...")
            let ctx = self.ctx
            Task.detached {
                let list = await Self.loadInstalled(ctx: ctx)
                SwifTea.dispatch(Action.listLoaded(list))
            }
        case .listLoaded(let list):
            model.toolchains = list
            model.screen = .list
            model.message = list.isEmpty ? "No installed toolchains." : "Installed toolchains."
        case .runSwitch:
            break
        case .operationResult(let msg):
            model.screen = .result(msg)
            model.message = msg
            model.input = ""
        case .exit:
            break
        }
    }

    func mapKeyToAction(_ key: KeyEvent) -> Action? {
        switch model.screen {
        case .menu, .result, .list, .progress:
            switch key {
            case .char("1"):
                return .start(.list)
            case .char("2"):
                return .start(.switchActive)
            case .char("3"):
                return .start(.install)
            case .char("4"):
                return .start(.uninstall)
            case .char("5"):
                return .start(.update)
            case .char("0"), .char("q"), .char("Q"):
                return .exit
            default:
                return nil
            }
        case .input:
            switch key {
            case .enter:
                return .submit
            case .backspace:
                return .backspace
            case .escape:
                return .cancelInput
            case .char(let ch):
                return .inputChar(ch)
            default:
                return nil
            }
        }
    }

    func shouldExit(for action: Action) -> Bool {
        if case .exit = action { return true }
        return false
    }

    mutating func initializeEffects() {
        // Start in menu; no preloading.
    }

    mutating func handleTerminalResize(from _: TerminalSize, to _: TerminalSize) {}
    mutating func handleFrame(deltaTime _: TimeInterval) {}

    private static func loadInstalled(ctx: SwiftlyCoreContext) async -> [ToolchainSummary] {
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

    private static func performSwitch(ctx: SwiftlyCoreContext, to target: String) async -> String {
        do {
            var config = try await Config.load(ctx)
            let selector = try ToolchainSelector(parsing: target)
            guard let toolchain = config.listInstalledToolchains(selector: selector).max() else {
                return "No installed toolchains match \"\(target)\""
            }
            _ = try await Use.execute(ctx, toolchain, globalDefault: false, verbose: false, assumeYes: true, &config)
            return "Switched to \(toolchain)"
        } catch {
            return "Switch failed: \(error)"
        }
    }
}

private struct RootTUIView: TUIView {
    typealias Body = Never
    let model: SwiftlyTUIApplication.Model

    var body: Never { fatalError("RootTUIView has no body") }

    func render() -> String {
        var lines: [String] = []
        lines.append("swiftly TUI")
        lines.append("----------------------")
        switch model.screen {
        case .menu, .result, .progress:
            lines.append("1) List toolchains")
            lines.append("2) Switch toolchain")
            lines.append("3) Install toolchain")
            lines.append("4) Uninstall toolchain")
            lines.append("5) Update toolchain")
            lines.append("0) Exit")
            lines.append("")
            lines.append(model.message)
        case .list:
            lines.append("Installed toolchains:")
            lines.append(contentsOf: model.toolchains.map { "- \($0.name) [\($0.channel)] \($0.status)" })
            lines.append("")
            lines.append("Press 0 to exit or 1 to refresh.")
        case .input(let type):
            lines.append("\(type.rawValue) - enter toolchain identifier:")
            lines.append("> \(model.input)")
            lines.append("Enter=submit, Esc=cancel")
        }
        return lines.joined(separator: "\n")
    }
}
