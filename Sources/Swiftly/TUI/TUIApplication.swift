import Foundation
import SwifTeaUI
import SwiftlyCore

private typealias ToolchainRow = (offset: Int, element: ToolchainViewModel)

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
        var focusedIndex: Int? = nil
        var navigationStack: [Screen] = []
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
        case moveFocus(Int)
        case openFocused
        case back
        case runSwitch(String)
        case operationResult(String)
        case operationSession(OperationSessionViewModel)
        case exit
    }

    var model: Model = Model()
    let ctx: SwiftlyCoreContext
    var adapterFactory: @Sendable (SwiftlyCoreContext) -> CoreActionsAdapter
    var controller: CoreActionsController

    init(ctx: SwiftlyCoreContext, adapterFactory: @escaping @Sendable (SwiftlyCoreContext) -> CoreActionsAdapter = { CoreActionsAdapter(ctx: $0) }) {
        self.ctx = ctx
        self.adapterFactory = adapterFactory
        self.controller = CoreActionsController(ctx: ctx, adapterFactory: adapterFactory)
    }

    func view(model: Model) -> some TUIView {
        RootTUIView(model: model)
    }

    mutating func update(action: Action) {
        switch action {
        case .showMenu:
            model.screen = .menu
            model.navigationStack = []
            model.message = "Use numbers to choose an action."
            model.input = ""
        case .start(let type):
            switch type {
            case .list:
                pushCurrentScreen()
                model.screen = .progress("Loading toolchains...")
                let controller = self.controller
                Task.detached {
                    let list = await controller.list()
                    SwifTea.dispatch(Action.listLoaded(list))
                }
            case .switchActive:
                model.screen = .input(.switchActive)
                model.input = ""
                model.message = "Enter toolchain to switch to:"
            case .install, .uninstall, .update:
                pushCurrentScreen()
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
                switch type {
                case .switchActive:
                    guard !value.isEmpty else {
                        model.message = "Input cannot be empty."
                        return
                    }
                    model.screen = .progress("Switching to \(value)...")
                    let controller = self.controller
                    Task.detached {
                        let session = await controller.switchToolchain(id: value)
                        SwifTea.dispatch(Action.operationSession(session))
                    }
                case .install:
                    let target = value
                    model.screen = .progress(target.isEmpty ? "Installing latest stable..." : "Installing \(target)...")
                    let controller = self.controller
                    Task.detached {
                        let session = await controller.install(id: target)
                        SwifTea.dispatch(Action.operationSession(session))
                    }
                case .uninstall:
                    guard !value.isEmpty else {
                        model.message = "Input cannot be empty."
                        return
                    }
                    model.screen = .progress("Removing \(value)...")
                    let controller = self.controller
                    Task.detached {
                        let session = await controller.remove(id: value)
                        SwifTea.dispatch(Action.operationSession(session))
                    }
                case .update:
                    let target = value
                    model.screen = .progress(target.isEmpty ? "Updating in-use toolchain..." : "Updating \(target)...")
                    let controller = self.controller
                    Task.detached {
                        let session = await controller.update(id: target)
                        SwifTea.dispatch(Action.operationSession(session))
                    }
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
            let controller = self.controller
            Task.detached {
                let list = await controller.list()
                SwifTea.dispatch(Action.listLoaded(list))
            }
        case .listLoaded(let list):
            model.toolchains = ListLayoutAdapter.sort(list)
            model.screen = .list
            model.focusedIndex = list.isEmpty ? nil : 0
            model.message = list.isEmpty ? "No installed toolchains. Choose Install to add one." : "Installed toolchains."
        case .selectIndex(let idx):
            guard model.toolchains.indices.contains(idx) else {
                model.message = "Invalid selection."
                return
            }
            pushCurrentScreen()
            let selected = model.toolchains[idx]
            model.focusedIndex = idx
            model.screen = .detail(selected)
            model.message = "Selected \(selected.identifier). Press 's' to switch, 'b' to go back."
        case .moveFocus(let delta):
            guard !model.toolchains.isEmpty else { return }
            let current = model.focusedIndex ?? 0
            let next = max(0, min(model.toolchains.count - 1, current + delta))
            model.focusedIndex = next
            model.message = "Focused \(model.toolchains[next].identifier). Enter to view."
        case .openFocused:
            guard model.screen == .list, let idx = model.focusedIndex else { return }
            self.update(action: .selectIndex(idx))
        case .back:
            if let previous = model.navigationStack.popLast() {
                model.screen = previous
                if case .list = previous, !model.toolchains.isEmpty {
                    model.message = "Back to list. j/k or arrows move, Enter opens."
                } else {
                    model.message = "Use numbers to choose an action."
                }
            } else {
                model.screen = .menu
                model.message = "Use numbers to choose an action."
            }
        case .confirmSwitchFromDetail:
            guard case .detail(let selected) = model.screen else { return }
            model.screen = .progress("Switching to \(selected.identifier)...")
            let controller = self.controller
            Task.detached {
                let session = await controller.switchToolchain(id: selected.identifier)
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
            case .upArrow, .char("k"):
                return .moveFocus(-1)
            case .downArrow, .char("j"):
                return .moveFocus(1)
            case .enter, .char(" "):
                return .openFocused
            case .char("b"), .char("B"):
                return .back
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
                return .back
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
                }
            case .list:
                let indexed = Array(model.toolchains.enumerated())
                return VStack(spacing: 1, alignment: .leading) {
                    header
                    divider
                    if indexed.isEmpty {
                        Text("No toolchains found. Choose Install to add one.")
                    } else {
                        let focused = model.focusedIndex
                        Table(
                            indexed,
                            id: \.element.identifier,
                            columnSpacing: 2,
                            rowSpacing: 0,
                            divider: .line(),
                            rowStyle: { (row: ToolchainRow, _) in
                                if focused == row.offset {
                                    return TableRowStyle.focusedWithMarkers()
                                }
                                return nil
                            }
                        ) {
                            TableColumn("#", width: .fixed(3), alignment: .trailing) { (pair: ToolchainRow) in
                                Text("\(pair.offset + 1)").foregroundColor(.brightBlack)
                            }
                            TableColumn("ID", width: .flex(min: 10)) { (pair: ToolchainRow) in
                                Text(pair.element.identifier).bold()
                            }
                            TableColumn("Channel", width: .fitContent) { (pair: ToolchainRow) in
                                Text(pair.element.channel.rawValue).foregroundColor(.brightBlack)
                            }
                            TableColumn("Status", width: .fitContent) { (pair: ToolchainRow) in
                                if pair.element.isActive {
                                    Text("active").foregroundColor(.green).bold()
                                } else {
                                    Text("installed")
                                }
                            }
                        }
                    }
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
                    if let last = model.lastSession {
                        Text("Last result: \(last.stateDescription)")
                    }
                }
            case .input(let type):
                let view: any TUIView = {
                    switch type {
                    case .install:
                        return InstallView(header: VStack { header; divider }, input: model.input)
                    case .update:
                        return UpdateView(header: VStack { header; divider }, input: model.input)
                    case .uninstall:
                        return RemoveView(header: VStack { header; divider }, input: model.input)
                    case .switchActive:
                        return VStack(spacing: 1, alignment: .leading) {
                            header
                            divider
                            Text("Switch - enter toolchain identifier:")
                            Text("> \(model.input)")
                        }
                    case .list, .exit:
                        return VStack(spacing: 1, alignment: .leading) { header; divider; Text("> \(model.input)") }
                    }
                }()
                return VStack(spacing: 1, alignment: .leading) {
                    view
                }
            }
        }()

        let status = StatusBar(
            leading: [
                StatusBar.Segment("Path: \(breadcrumb(for: model.screen))", color: .brightBlack),
                StatusBar.Segment(model.message, color: .white)
            ],
            trailing: [
                StatusBar.Segment(hints(for: model.screen), color: .brightBlack)
            ]
        )

        return VStack(spacing: 1, alignment: .leading) {
            content
            status
        }.render()
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

private func breadcrumb(for screen: SwiftlyTUIApplication.Model.Screen) -> String {
    switch screen {
    case .menu:
        return "Home"
    case .list:
        return "Home > Toolchains"
    case .detail(let toolchain):
        return "Home > Toolchains > \(toolchain.identifier)"
    case .input(let type):
        return "Home > \(type.rawValue.capitalized)"
    case .progress:
        return "Home > Working"
    case .result:
        return "Home > Result"
    }
}

private func hints(for screen: SwiftlyTUIApplication.Model.Screen) -> String {
    switch screen {
    case .menu:
        return "1 list · 2 switch · 3 install · 4 uninstall · 5 update · 0/q exit"
    case .list:
        return "j/k/arrow move · Enter/Space open · # jump · 1 refresh · b back · 0/q exit"
    case .detail:
        return "s switch · b back · q exit"
    case .input:
        return "Enter submit · Esc cancel · q exit"
    case .progress:
        return "Working… q exit"
    case .result:
        return "1 refresh list · b back · 0/q exit"
    }
}

private extension SwiftlyTUIApplication {
    mutating func pushCurrentScreen() {
        model.navigationStack.append(model.screen)
    }
}
