import Foundation
import SwiftlyCore
import SwifTeaUI

struct SwiftlyTUIApplication: TUIScene {
    struct Model {
        enum Screen: Equatable {
            case menu
            case list
            case installList
            case detail(ToolchainViewModel)
            case input(ActionType)
            case progress(String)
            case result(String)
            case error(OperationSessionViewModel)
        }

        var screen: Screen = .menu
        var toolchains: [ToolchainViewModel] = []
        var availableToolchains: [ToolchainViewModel] = []
        var message: String = "Use numbers to choose an action."
        var input: String = ""
        var lastSession: OperationSessionViewModel?
        var focusedIndex: Int? = nil
        var navigationStack: [Screen] = []
        var filter: String = ""
        var isFiltering: Bool = false
        var listScrollOffset: Int = 0
    }

    enum ActionType: String {
        case list = "List"
        case install = "Install"
    }

    enum Action {
        case showMenu
        case start(ActionType)
        case statsLoaded([ToolchainViewModel])
        case inputChar(Character)
        case backspace
        case submit
        case cancelInput
        case loadList
        case listLoaded([ToolchainViewModel])
        case loadAvailable
        case availableLoaded(AvailableToolchainsResult)
        case selectIndex(Int)
        case confirmSwitchFromDetail
        case moveFocus(Int)
        case openFocused
        case back
        case runSwitch(String)
        case operationResult(String)
        case operationSession(OperationSessionViewModel)
        case retryLast
        case cancelRecovery
        case exit
        case startFilter
        case filterChar(Character)
        case filterBackspace
        case clearFilter
        case setListOffset(Int)
        case switchFocused
        case startManualInstall
        case installFocused
        case detailUninstall(ToolchainViewModel)
        case detailUpdate(ToolchainViewModel)
    }

    var model: Model = Model()
    let ctx: SwiftlyCoreContext
    var adapterFactory: @Sendable (SwiftlyCoreContext) -> CoreActionsAdapter
    var controller: CoreActionsController
    var recovery: OperationRecoveryController
    var overlayPresenter: OverlayPresenter = OverlayPresenter()
    private let theme: SwifTeaTheme = .basic

    init(ctx: SwiftlyCoreContext, adapterFactory: @escaping @Sendable (SwiftlyCoreContext) -> CoreActionsAdapter = { CoreActionsAdapter(ctx: $0) }) {
        self.ctx = ctx
        self.adapterFactory = adapterFactory
        self.controller = CoreActionsController(ctx: ctx, adapterFactory: adapterFactory)
        self.recovery = OperationRecoveryController(ctx: ctx, controller: self.controller)
    }

    func view(model: Model) -> some TUIView {
        RootTUIView(model: model, overlay: overlayPresenter, theme: theme)
    }
}

extension SwiftlyTUIApplication {
    mutating func update(action: Action) {
        switch action {
        case .showMenu:
        model.screen = .menu
        model.navigationStack = []
        model.message = "Use numbers to choose an action."
        model.input = ""
        model.filter = ""
        model.isFiltering = false
        model.listScrollOffset = 0
        model.focusedIndex = nil
            model.availableToolchains = []
            let controller = self.controller
            Task.detached {
                if let pending = await controller.loadPendingSession() {
                    SwifTea.dispatch(Action.operationSession(pending))
                }
            }
            Task.detached {
                let list = await controller.list()
                SwifTea.dispatch(Action.statsLoaded(list))
            }
        case .start(let type):
            switch type {
            case .list:
                pushCurrentScreen()
                model.screen = .progress("Loading toolchains...")
                model.listScrollOffset = 0
                let controller = self.controller
                Task.detached {
                    let list = await controller.list()
                    SwifTea.dispatch(Action.listLoaded(list))
                }
            case .install:
                pushCurrentScreen()
                model.screen = .progress("Loading available toolchains...")
                model.listScrollOffset = 0
                model.filter = ""
                model.isFiltering = false
                model.availableToolchains = []
                model.focusedIndex = nil
                let controller = self.controller
                Task.detached {
                    let result = await controller.listAvailable()
                    SwifTea.dispatch(Action.availableLoaded(result))
                }
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
                case .install:
                    let target = value
                    if !target.isEmpty {
                        do {
                            _ = try ToolchainSelector(parsing: target)
                        } catch {
                            model.message = "Invalid identifier: \(error)"
                            return
                        }
                    }
                    model.screen = .progress(target.isEmpty ? "Installing latest stable..." : "Installing \(target)...")
                    let controller = self.controller
                    Task.detached {
                        let session = await controller.install(id: target)
                        SwifTea.dispatch(Action.operationSession(session))
                    }
                case .list:
                    break
                }
            default:
                break
            }
        case .cancelInput:
            if let previous = model.navigationStack.popLast() {
                model.screen = previous
            } else {
                model.screen = .menu
            }
            model.input = ""
            model.filter = ""
            model.isFiltering = false
            model.message = {
                switch model.screen {
                case .installList:
                    return "Available toolchains. Enter installs · / filters · m manual."
                case .list:
                    return "Installed toolchains. Enter opens detail, s switches."
                default:
                    return "Use numbers to choose an action."
                }
            }()
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
            let filtered = filteredToolchains(model)
            model.focusedIndex = filtered.isEmpty ? nil : 0
            model.listScrollOffset = adjustedListOffset(
                focused: model.focusedIndex ?? 0,
                total: filtered.count,
                viewport: LayoutSizing.listViewport,
                currentOffset: 0
            )
            model.message = filtered.isEmpty
                ? "No installed toolchains. Choose Install to add one."
                : "Installed toolchains. Enter opens detail, s switches."
        case .statsLoaded(let list):
            model.toolchains = ListLayoutAdapter.sort(list)
        case .loadAvailable:
            model.screen = .progress("Loading available toolchains...")
            let controller = self.controller
            Task.detached {
                let result = await controller.listAvailable()
                SwifTea.dispatch(Action.availableLoaded(result))
            }
        case .availableLoaded(let result):
            model.availableToolchains = ListLayoutAdapter.sort(result.toolchains)
            model.screen = .installList
            let filtered = filteredAvailableToolchains(model)
            model.focusedIndex = filtered.isEmpty ? nil : 0
            model.listScrollOffset = adjustedListOffset(
                focused: model.focusedIndex ?? 0,
                total: filtered.count,
                viewport: LayoutSizing.listViewport,
                currentOffset: 0
            )
            if let message = result.errorMessage, !message.isEmpty {
                model.message = result.toolchains.isEmpty
                    ? "\(message) Press m to enter manually."
                    : "\(message) Showing available releases."
            } else {
                model.message = filtered.isEmpty
                    ? "No available toolchains. Press m to enter manually."
                    : "Available toolchains. Enter installs · / filters · m manual."
            }
        case .selectIndex(let idx):
            let filtered = filteredToolchains(model)
            guard filtered.indices.contains(idx) else {
                model.message = "Invalid selection."
                return
            }
            pushCurrentScreen()
            let selected = filtered[idx]
            model.focusedIndex = idx
            model.screen = .detail(selected)
            model.message = "Selected \(selected.identifier). Press 's' to switch, 'u' uninstall, 'p' update, 'b' go back."
        case .moveFocus(let delta):
            let filtered = currentFilteredToolchains(model)
            guard !filtered.isEmpty else { return }
            let current = model.focusedIndex ?? 0
            let next = max(0, min(filtered.count - 1, current + delta))
            model.focusedIndex = next
            if case .installList = model.screen {
                model.message = "Focused \(filtered[next].identifier). Enter installs."
            } else {
                model.message = "Focused \(filtered[next].identifier). Enter to view."
            }
            model.listScrollOffset = adjustedListOffset(
                focused: next,
                total: filtered.count,
                viewport: LayoutSizing.listViewport,
                currentOffset: model.listScrollOffset
            )
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
        case .detailUninstall(let toolchain):
            model.screen = .progress("Removing \(toolchain.identifier)...")
            let controller = self.controller
            Task.detached {
                let session = await controller.remove(id: toolchain.identifier)
                SwifTea.dispatch(Action.operationSession(session))
            }
        case .detailUpdate(let toolchain):
            model.screen = .progress("Updating \(toolchain.identifier)...")
            let controller = self.controller
            Task.detached {
                let session = await controller.update(id: toolchain.identifier)
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
                overlayPresenter.presentToast(style: .success) {
                    Text(message).bold()
                }
            case .failed(let message, _):
                model.screen = .error(session)
                model.message = message
                overlayPresenter.presentToast(style: .error) {
                    Text(message).bold()
                }
            case .cancelled(let message, _):
                model.screen = .error(session)
                model.message = message ?? "Cancelled"
                overlayPresenter.presentToast(style: .warning) {
                    Text(message ?? "Cancelled")
                }
            case .pending, .running:
                model.screen = .progress("Running...")
            }
        case .retryLast:
            guard let session = model.lastSession else { return }
            let target = session.targetIdentifier ?? ""
            model.screen = .progress("Retrying \(target)...")
            let recovery = self.recovery
            Task.detached {
                let next = await recovery.retryLastOperation(session)
                SwifTea.dispatch(Action.operationSession(next))
            }
        case .cancelRecovery:
            model.screen = .menu
            model.message = "Operation cancelled."
            model.navigationStack = []
        case .exit:
            break
        case .startFilter:
            model.isFiltering = true
            if model.filter.isEmpty {
                model.message = "Filter toolchains: type to narrow, Esc to clear."
            }
        case .filterChar(let ch):
            guard model.isFiltering else { return }
            model.filter.append(ch)
            let filtered = currentFilteredToolchains(model)
            model.focusedIndex = filtered.isEmpty ? nil : 0
            model.listScrollOffset = adjustedListOffset(
                focused: model.focusedIndex ?? 0,
                total: filtered.count,
                viewport: LayoutSizing.listViewport,
                currentOffset: model.listScrollOffset
            )
            model.message = filtered.isEmpty ? "No matches for '\(model.filter)'." : "Filter: \(model.filter)"
        case .filterBackspace:
            guard model.isFiltering else { return }
            if !model.filter.isEmpty { model.filter.removeLast() }
            let filtered = currentFilteredToolchains(model)
            model.focusedIndex = filtered.isEmpty ? nil : 0
            model.listScrollOffset = adjustedListOffset(
                focused: model.focusedIndex ?? 0,
                total: filtered.count,
                viewport: LayoutSizing.listViewport,
                currentOffset: model.listScrollOffset
            )
            model.message = model.filter.isEmpty ? "Filter cleared; showing all." : "Filter: \(model.filter)"
        case .clearFilter:
            model.isFiltering = false
            model.filter = ""
            let filtered = currentFilteredToolchains(model)
            model.focusedIndex = filtered.isEmpty ? nil : 0
            model.listScrollOffset = adjustedListOffset(
                focused: model.focusedIndex ?? 0,
                total: filtered.count,
                viewport: LayoutSizing.listViewport,
                currentOffset: 0
            )
            model.message = filtered.isEmpty ? "No toolchains to show." : "Filter cleared; showing all."
        case .setListOffset(let offset):
            model.listScrollOffset = max(0, offset)
        case .switchFocused:
            guard model.screen == .list,
                  let idx = model.focusedIndex else { return }
            let filtered = filteredToolchains(model)
            guard filtered.indices.contains(idx) else { return }
            let target = filtered[idx].identifier
            model.screen = .progress("Switching to \(target)...")
            let controller = self.controller
            Task.detached {
                let session = await controller.switchToolchain(id: target)
                SwifTea.dispatch(Action.operationSession(session))
            }
        case .startManualInstall:
            pushCurrentScreen()
            model.screen = .input(.install)
            model.input = ""
            model.message = "Enter toolchain identifier for install:"
            model.isFiltering = false
            model.filter = ""
        case .installFocused:
            guard case .installList = model.screen,
                  let idx = model.focusedIndex else { return }
            let filtered = filteredAvailableToolchains(model)
            guard filtered.indices.contains(idx) else { return }
            let target = filtered[idx].identifier
            model.screen = .progress("Installing \(target)...")
            let controller = self.controller
            Task.detached {
                let session = await controller.install(id: target)
                SwifTea.dispatch(Action.operationSession(session))
            }
        }
    }

}
