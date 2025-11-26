import Foundation
import SwifTeaUI
import SwiftlyCore

struct SwiftlyTUIApplication: TUIScene {
    struct Model {
        enum Screen: Equatable {
            case menu
            case list
            case detail(ToolchainViewModel)
            case input(ActionType)
            case progress(String)
            case result(String)
        }

        var screen: Screen = .menu
        var toolchains: [ToolchainViewModel] = []
        var message: String = "Use numbers to choose an action."
        var input: String = ""
        var lastSession: OperationSessionViewModel?
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
        case listLoaded([ToolchainViewModel])
        case selectIndex(Int)
        case confirmSwitchFromDetail
        case runSwitch(String)
        case operationResult(String)
        case operationSession(OperationSessionViewModel)
        case exit
    }

    var model: Model = Model()
    let ctx: SwiftlyCoreContext
    var adapterFactory: @Sendable (SwiftlyCoreContext) -> CoreActionsAdapter

    init(ctx: SwiftlyCoreContext, adapterFactory: @escaping @Sendable (SwiftlyCoreContext) -> CoreActionsAdapter = { CoreActionsAdapter(ctx: $0) }) {
        self.ctx = ctx
        self.adapterFactory = adapterFactory
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
                let factory = adapterFactory
                Task.detached {
                    let adapter = factory(ctx)
                    let list = await adapter.listToolchains()
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
                    let factory = adapterFactory
                    Task.detached {
                        let adapter = factory(ctx)
                        let session = await adapter.activateToolchain(id: value)
                        SwifTea.dispatch(Action.operationSession(session))
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
            let factory = adapterFactory
            Task.detached {
                let adapter = factory(ctx)
                let list = await adapter.listToolchains()
                SwifTea.dispatch(Action.listLoaded(list))
            }
        case .listLoaded(let list):
            model.toolchains = ListLayoutAdapter.sort(list)
            model.screen = .list
            model.message = list.isEmpty ? "No installed toolchains. Choose Install to add one." : "Installed toolchains."
        case .selectIndex(let idx):
            guard model.toolchains.indices.contains(idx) else {
                model.message = "Invalid selection."
                return
            }
            let selected = model.toolchains[idx]
            model.screen = .detail(selected)
            model.message = "Selected \(selected.identifier). Press 's' to switch, 'b' to go back."
        case .confirmSwitchFromDetail:
            guard case .detail(let selected) = model.screen else { return }
            model.screen = .progress("Switching to \(selected.identifier)...")
            let ctx = self.ctx
            let factory = adapterFactory
            Task.detached {
                let adapter = factory(ctx)
                let session = await adapter.activateToolchain(id: selected.identifier)
                SwifTea.dispatch(Action.operationSession(session))
            }
        case .runSwitch:
            break
        case .operationResult(let msg):
            model.screen = .result(msg)
            model.message = msg
            model.input = ""
        case .operationSession(let session):
            model.lastSession = session
            switch session.state {
            case .succeeded(let message):
                model.screen = .result(message)
                model.message = message
            case .failed(let message, _):
                model.screen = .result(message)
                model.message = message
            case .cancelled(let message, _):
                model.screen = .result(message ?? "Cancelled")
                model.message = message ?? "Cancelled"
            case .pending, .running:
                model.screen = .progress("Running...")
            }
        case .exit:
            break
        }
    }

    func mapKeyToAction(_ key: KeyEvent) -> Action? {
        switch model.screen {
        case .menu, .result, .progress:
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
        case .list:
            switch key {
            case .char(let ch) where ("0"..."9").contains(ch):
                guard let idx = Int(String(ch)) else { return nil }
                if idx == 0 { return .exit }
                return .selectIndex(idx - 1)
            case .char("1"):
                return .start(.list) // refresh
            case .char("q"), .char("Q"):
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
        case .detail:
            switch key {
            case .char("s"), .char("S"):
                return .confirmSwitchFromDetail
            case .char("b"), .char("B"):
                return .showMenu
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
}

private struct RootTUIView: TUIView {
    typealias Body = Never
    let model: SwiftlyTUIApplication.Model

    var body: Never { fatalError("RootTUIView has no body") }

    func render() -> String {
        let header = Text("swiftly TUI").bold()
        let divider = Text("----------------------")

        let content: any TUIView = {
            switch model.screen {
            case .menu:
                return VStack(spacing: 1, alignment: .leading) {
                    header
                    divider
                    Text("1) List toolchains")
                    Text("2) Switch toolchain")
                    Text("3) Install toolchain")
                    Text("4) Uninstall toolchain")
                    Text("5) Update toolchain")
                    Text("0) Exit")
                    Text("")
                    Text(model.message)
                }
            case .progress(let message):
                return VStack(spacing: 1, alignment: .leading) {
                    header
                    divider
                    Text(message)
                }
            case .result(let message):
                return VStack(spacing: 1, alignment: .leading) {
                    header
                    divider
                    Text(message)
                    Text("")
                    Text("Press 0 to exit or 1 to refresh list.")
                }
            case .list:
                let indexed = Array(model.toolchains.enumerated())
                return VStack(spacing: 1, alignment: .leading) {
                    header
                    divider
                    if indexed.isEmpty {
                        Text("No toolchains found. Choose Install to add one.")
                    } else {
                        Table(
                            indexed,
                            id: \.element.identifier,
                            columnSpacing: 2,
                            rowSpacing: 0,
                            divider: .line()
                        ) {
                            TableColumn("#", width: .fixed(3), alignment: .trailing) { pair in
                                let pair: (offset: Int, element: ToolchainViewModel) = pair
                                Text("\(pair.offset + 1)").foregroundColor(.brightBlack)
                            }
                            TableColumn("ID", width: .flex(min: 10)) { pair in
                                let pair: (offset: Int, element: ToolchainViewModel) = pair
                                Text(pair.element.identifier).bold()
                            }
                            TableColumn("Channel", width: .fitContent) { pair in
                                let pair: (offset: Int, element: ToolchainViewModel) = pair
                                Text(pair.element.channel.rawValue).foregroundColor(.brightBlack)
                            }
                            TableColumn("Status", width: .fitContent) { pair in
                                let pair: (offset: Int, element: ToolchainViewModel) = pair
                                if pair.element.isActive {
                                    Text("active").foregroundColor(.green).bold()
                                } else {
                                    Text("installed")
                                }
                            }
                        }
                    }
                    Text("")
                    Text("Enter number to view details, 1 to refresh, 0 to exit.")
                    Text(model.message)
                }
            case .detail(let toolchain):
                return VStack(spacing: 1, alignment: .leading) {
                    header
                    divider
                    Text("Toolchain: \(toolchain.identifier)").bold()
                    Text("Channel: \(toolchain.channel.rawValue)")
                    Text("Status: \(toolchain.isActive ? "active" : "installed")")
                    if let location = toolchain.location { Text("Location: \(location)") }
                    if let meta = toolchain.metadata?.sizeDescription { Text("Size: \(meta)") }
                    Text("")
                    Text("Press 's' to switch, 'b' to go back.")
                    if let last = model.lastSession {
                        Text("Last result: \(last.stateDescription)")
                    }
                }
            case .input(let type):
                return VStack(spacing: 1, alignment: .leading) {
                    header
                    divider
                    Text("\(type.rawValue) - enter toolchain identifier:")
                    Text("> \(model.input)")
                    Text("Enter=submit, Esc=cancel")
                    Text(model.message)
                }
            }
        }()

        return content.render()
    }
}

private extension OperationSessionViewModel.State {
    var humanDescription: String {
        switch self {
        case .pending:
            return "pending"
        case .running(let progress, let message):
            let msg = message.map { " - \($0)" } ?? ""
            return "running \(progress)%\(msg)"
        case .succeeded(let message):
            return "success: \(message)"
        case .failed(let message, let logPath):
            let log = logPath.map { " (log: \($0))" } ?? ""
            return "failed: \(message)\(log)"
        case .cancelled(let message, let logPath):
            let msg = message ?? "cancelled"
            let log = logPath.map { " (log: \($0))" } ?? ""
            return "\(msg)\(log)"
        }
    }
}

private extension OperationSessionViewModel {
    var stateDescription: String { state.humanDescription }
}
