import Foundation
import SwifTeaUI
import SwiftlyCore

private typealias ToolchainRow = (offset: Int, element: ToolchainViewModel)

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
            case .uninstall, .update:
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
            model.message = "Selected \(selected.identifier). Press 's' to switch, 'b' to go back."
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

    func mapKeyToAction(_ key: KeyEvent) -> Action? {
        switch model.screen {
        case .menu, .result, .progress:
            switch key {
            case .char("1"):
                return .start(.list)
            case .char("2"):
                return .start(.install)
            case .char("3"):
                return .start(.uninstall)
            case .char("4"):
                return .start(.update)
            case .char("0"), .char("q"), .char("Q"):
                return .exit
            default:
                return nil
            }
        case .installList:
            switch key {
            case .upArrow, .char("k"):
                return .moveFocus(-1)
            case .downArrow, .char("j"):
                return .moveFocus(1)
            case .enter, .char(" "):
                return .installFocused
            case .char("/"):
                return .startFilter
            case .char(let ch) where model.isFiltering:
                return .filterChar(ch)
            case .backspace:
                return model.isFiltering ? .filterBackspace : nil
            case .escape:
                return (model.isFiltering || !model.filter.isEmpty) ? .clearFilter : nil
            case .char("m"), .char("M"):
                return .startManualInstall
            case .char("b"), .char("B"):
                return .back
            case .char("0"), .char("q"), .char("Q"):
                return .exit
            default:
                return nil
            }
        case .list:
            switch key {
            case .char(let ch) where ("0"..."9").contains(ch):
                guard !model.isFiltering else { return .filterChar(ch) }
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
            case .char("s"), .char("S"):
                return .switchFocused
            case .char("b"), .char("B"):
                return .back
            case .char("/"):
                return .startFilter
            case .char(let ch):
                if model.isFiltering { return .filterChar(ch) }
                return nil
            case .backspace:
                if model.isFiltering { return .filterBackspace }
                return nil
            case .escape:
                if model.isFiltering || !model.filter.isEmpty { return .clearFilter }
                return nil
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
        case .error:
            switch key {
            case .char("r"), .char("R"):
                return .retryLast
            case .char("c"), .char("C"):
                return .cancelRecovery
            case .char("b"), .char("B"):
                return .back
            case .char("q"), .char("Q"), .char("0"):
                return .exit
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
    mutating func handleFrame(deltaTime: TimeInterval) {
        overlayPresenter.tick(deltaTime: deltaTime)
    }
}

private struct RootTUIView: TUIView {
    typealias Body = Never
    let model: SwiftlyTUIApplication.Model
    let overlay: OverlayPresenter
    let theme: SwifTeaTheme

    var body: Never { fatalError("RootTUIView has no body") }

    func render() -> String {
        OverlayHost(presenter: overlay) {
            VStack(spacing: 1, alignment: .leading) {
                ScreenFrame(model: model, theme: theme)
                statusBar
                Text("") // reserve a line for bottom toasts without overwriting status content
            }
        }.render()
    }

    private var statusBar: StatusBar {
        StatusBar(
            leading: [
                StatusBar.Segment("Path: \(breadcrumb(for: model.screen))", color: theme.mutedText),
                StatusBar.Segment(model.message, color: theme.primaryText)
            ],
            trailing: [
                StatusBar.Segment(KeyboardHints.description(for: hintContext(for: model.screen)), color: theme.mutedText)
            ]
        )
    }

    private func hintContext(for screen: SwiftlyTUIApplication.Model.Screen) -> KeyboardHints.Context {
        switch screen {
        case .menu: return .menu
        case .installList: return .installList
        case .list: return .list
        case .detail: return .detail
        case .input: return .input
        case .progress: return .progress
        case .result: return .result
        case .error: return .error
        }
    }
}

/// Shared frame for all screens: header + body wrapped in a simple layout.
private struct ScreenFrame: TUIView {
    typealias Body = Never
    let model: SwiftlyTUIApplication.Model
    let theme: SwifTeaTheme

    var body: Never { fatalError("ScreenFrame has no body") }

    func render() -> String {
        Border(
            padding: 1,
            color: theme.frameBorder,
            background: theme.background,
            ZStack(alignment: .topLeading) {
                FixedSpace(width: LayoutSizing.contentWidth, height: LayoutSizing.minHeight(for: model.screen))
                VStack(spacing: 1, alignment: .leading) {
                    Text("swiftly TUI")
                        .foregroundColor(theme.accent)
                        .bold()
                    Text("----------------------")
                        .foregroundColor(theme.mutedText)
                    bodyContent()
                }
            }
        ).render()
    }

    private func bodyContent() -> any TUIView {
        switch model.screen {
        case .menu:
            return VStack(spacing: 1, alignment: .leading) {
                Text("1) List & switch toolchains")
                Text("2) Install toolchain")
                Text("3) Uninstall toolchain")
                Text("4) Update toolchain")
                Text("0) Exit")
            }
        case .progress(let message):
            let running = model.lastSession
            return VStack(spacing: 1, alignment: .leading) {
                if let state = running?.state, case .running(let percent, let detail) = state {
                    Spinner(label: detail ?? message, style: .dots, color: theme.accent, isBold: true)
                    ProgressMeter(
                        value: Double(percent) / 100.0,
                        width: 24,
                        style: .tinted(theme.accent),
                        showsPercentage: true
                    )
                } else {
                    Spinner(label: message, style: .dots, color: theme.accent, isBold: true)
                }
            }
        case .result(let message):
            return VStack(spacing: 1, alignment: .leading) {
                Text(message)
            }
        case .list:
            let filtered = filteredToolchains(model)
            let indexed = Array(filtered.enumerated())
            let rowSpacing = ListLayoutAdapter.rowSpacing(for: indexed.count)
            if indexed.isEmpty {
                let empty = ListLayoutAdapter.emptyState()
                return VStack(spacing: 1, alignment: .leading) {
                    Text(empty.title).foregroundColor(theme.primaryText)
                    Text(empty.guidance).foregroundColor(theme.mutedText)
                }
            } else {
                let focused = model.focusedIndex
                let layout = ListLayoutAdapter.columnLayout()
                let offsetBinding = Binding<Int>(
                    get: { model.listScrollOffset },
                    set: { SwifTea.dispatch(SwiftlyTUIApplication.Action.setListOffset($0)) }
                )
                let activeLine = Binding<Int>(
                    get: { focused ?? 0 },
                    set: { _ in }
                )
                let filterLine = Text("Filter: \(model.filter)")
                    .foregroundColor(model.filter.isEmpty ? theme.mutedText : theme.accent)
                return VStack(spacing: 1, alignment: .leading) {
                    filterLine
                    ScrollView(
                        .vertical,
                        viewport: LayoutSizing.listViewport,
                        offset: offsetBinding,
                        activeLine: activeLine,
                        followActiveLine: Binding.constant(true),
                        content: {
                            Table(
                                indexed,
                                id: \.element.identifier,
                                columnSpacing: layout.columnSpacing,
                                rowSpacing: rowSpacing,
                                divider: .line(),
                                rowStyle: { (row: ToolchainRow, _) in
                                    AccessibilityStyles.focusedRowStyle(hasFocus: focused == row.offset, theme: theme)
                                }
                            ) {
                                TableColumn("#", width: .fixed(3), alignment: .trailing) { (pair: ToolchainRow) in
                                    Text("\(pair.offset + 1)").foregroundColor(theme.mutedText)
                                }
                                TableColumn("ID", width: .flex(min: layout.idMinWidth)) { (pair: ToolchainRow) in
                                    let id = ListLayoutAdapter.truncateIdentifier(pair.element.identifier)
                                    Text(id)
                                        .foregroundColor(theme.primaryText)
                                        .bold()
                                }
                                TableColumn("Channel", width: .fitContent) { (pair: ToolchainRow) in
                                    Text(pair.element.channel.rawValue).foregroundColor(theme.mutedText)
                                }
                                TableColumn("Status", width: .fitContent) { (pair: ToolchainRow) in
                                    if pair.element.isActive {
                                        Text("active").foregroundColor(theme.success).bold()
                                    } else {
                                        Text("installed").foregroundColor(theme.primaryText)
                                    }
                                }
                            }
                        }
                    )
                }
            }
        case .installList:
            let filtered = filteredAvailableToolchains(model)
            let indexed = Array(filtered.enumerated())
            let rowSpacing = ListLayoutAdapter.rowSpacing(for: indexed.count)
            if indexed.isEmpty {
                return VStack(spacing: 1, alignment: .leading) {
                    Text("No available toolchains fetched.")
                    Text("Press m to enter manually or refresh.")
                        .foregroundColor(theme.mutedText)
                }
            } else {
                let focused = model.focusedIndex
                let layout = ListLayoutAdapter.columnLayout()
                let offsetBinding = Binding<Int>(
                    get: { model.listScrollOffset },
                    set: { SwifTea.dispatch(SwiftlyTUIApplication.Action.setListOffset($0)) }
                )
                let activeLine = Binding<Int>(
                    get: { focused ?? 0 },
                    set: { _ in }
                )
                let filterLine = Text("Filter: \(model.filter)")
                    .foregroundColor(model.filter.isEmpty ? theme.mutedText : theme.accent)
                return VStack(spacing: 1, alignment: .leading) {
                    filterLine
                    ScrollView(
                        .vertical,
                        viewport: LayoutSizing.listViewport,
                        offset: offsetBinding,
                        activeLine: activeLine,
                        followActiveLine: Binding.constant(true),
                        content: {
                            Table(
                                indexed,
                                id: \.element.identifier,
                                columnSpacing: layout.columnSpacing,
                                rowSpacing: rowSpacing,
                                divider: .line(),
                                rowStyle: { (row: ToolchainRow, _) in
                                    AccessibilityStyles.focusedRowStyle(hasFocus: focused == row.offset, theme: theme)
                                }
                            ) {
                                TableColumn("#", width: .fixed(3), alignment: .trailing) { (pair: ToolchainRow) in
                                    Text("\(pair.offset + 1)").foregroundColor(theme.mutedText)
                                }
                                TableColumn("ID", width: .flex(min: layout.idMinWidth)) { (pair: ToolchainRow) in
                                    let id = ListLayoutAdapter.truncateIdentifier(pair.element.identifier)
                                    Text(id)
                                        .foregroundColor(theme.primaryText)
                                        .bold()
                                }
                                TableColumn("Channel", width: .fitContent) { (pair: ToolchainRow) in
                                    Text(pair.element.channel.rawValue).foregroundColor(theme.mutedText)
                                }
                                TableColumn("Status", width: .fitContent) { (pair: ToolchainRow) in
                                    if pair.element.isActive {
                                        Text("in-use").foregroundColor(theme.success).bold()
                                    } else if pair.element.isInstalled {
                                        Text("installed").foregroundColor(theme.primaryText)
                                    } else {
                                        Text("available").foregroundColor(theme.mutedText)
                                    }
                                }
                            }
                        }
                    )
                }
            }
        case .detail(let toolchain):
            return VStack(spacing: 1, alignment: .leading) {
                Text("Toolchain: \(toolchain.identifier)").bold().foregroundColor(theme.primaryText)
                Text("Channel: \(toolchain.channel.rawValue)").foregroundColor(theme.mutedText)
                Text("Status: \(toolchain.isActive ? "active" : "installed")").foregroundColor(theme.primaryText)
                if let location = toolchain.location { Text("Location: \(location)").foregroundColor(theme.primaryText) }
                if let meta = toolchain.metadata?.sizeDescription { Text("Size: \(meta)").foregroundColor(theme.mutedText) }
                if let last = model.lastSession {
                    Text("Last result: \(last.stateDescription)").foregroundColor(theme.mutedText)
                }
            }
        case .error(let session):
            return ErrorView(
                message: session.state.humanErrorMessage,
                suggestion: "Retry (r) or Cancel (c)",
                logPath: session.logPath
            )
        case .input(let type):
            switch type {
            case .install:
                return InstallView(header: EmptyHeader(), input: model.input, validation: validationMessage(for: type))
            case .update:
                return UpdateView(header: EmptyHeader(), input: model.input, validation: validationMessage(for: type))
            case .uninstall:
                return RemoveView(header: EmptyHeader(), input: model.input, validation: validationMessage(for: type))
            case .list, .exit:
                return VStack(spacing: 1, alignment: .leading) { Text(AccessibilityStyles.focusIndicator(for: model.input)) }
            }
        }
    }

    private func validationMessage(for type: SwiftlyTUIApplication.ActionType) -> String? {
        let defaults: [SwiftlyTUIApplication.ActionType: String] = [
            .install: "Enter toolchain identifier for install:",
            .update: "Enter toolchain identifier for update:",
            .uninstall: "Enter toolchain identifier for uninstall:"
        ]
        guard let expected = defaults[type] else { return nil }
        let current = model.message
        if current == expected { return nil }
        if current.hasPrefix("Enter toolchain identifier") { return nil } // still prompt-like
        return current
    }
}

/// Placeholder to keep Install/Update/Remove headers consistent without duplicating the frame layout.
private struct EmptyHeader: TUIView {
    typealias Body = Never
    var body: Never { fatalError("EmptyHeader has no body") }
    func render() -> String { "" }
}

/// Provides a baseline width/height so all screens share consistent framing.
private struct FixedSpace: TUIView {
    typealias Body = Never
    let width: Int
    let height: Int

    var body: Never { fatalError("FixedSpace has no body") }

    func render() -> String {
        let safeWidth = max(0, width)
        let line = String(repeating: " ", count: safeWidth)
        let rows = max(1, height)
        return Array(repeating: line, count: rows).joined(separator: "\n")
    }
}

internal extension OperationSessionViewModel.State {
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

    var humanErrorMessage: String {
        switch self {
        case .failed(let message, let logPath):
            let log = logPath.map { " (log: \($0))" } ?? ""
            return "Failed: \(message)\(log)"
        case .cancelled(let message, let logPath):
            let msg = message ?? "Cancelled"
            let log = logPath.map { " (log: \($0))" } ?? ""
            return "\(msg)\(log)"
        case .pending, .running, .succeeded:
            return humanDescription
        }
    }
}

private extension OperationSessionViewModel {
    var stateDescription: String { state.humanDescription }
    var stateErrorDescription: String { state.humanErrorMessage }
}

/// Layout sizing rules for consistent framing across screens.
private enum LayoutSizing {
    static let contentWidth: Int = 72
    static let baseHeight: Int = 18
    // Account for filter line + table header/divider; the remainder is usable data rows.
    static let listViewport: Int = max(8, baseHeight - 7) // 18 -> ~9 data rows

    static func minHeight(for screen: SwiftlyTUIApplication.Model.Screen) -> Int {
        // Keep a consistent baseline height across all screens; taller views can extend naturally.
        return baseHeight
    }
}

/// Returns the filtered toolchains based on the current filter string.
private func filteredToolchains(_ model: SwiftlyTUIApplication.Model) -> [ToolchainViewModel] {
    guard !model.filter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        return model.toolchains
    }
    let query = model.filter.lowercased()
    return model.toolchains.filter { tc in
        tc.identifier.lowercased().contains(query) || tc.channel.rawValue.lowercased().contains(query)
    }
}

/// Returns the filtered available toolchains based on the current filter string.
private func filteredAvailableToolchains(_ model: SwiftlyTUIApplication.Model) -> [ToolchainViewModel] {
    guard !model.filter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        return model.availableToolchains
    }
    let query = model.filter.lowercased()
    return model.availableToolchains.filter { tc in
        tc.identifier.lowercased().contains(query) || tc.channel.rawValue.lowercased().contains(query)
    }
}

/// Returns the filtered toolchains for the active list-like screen.
private func currentFilteredToolchains(_ model: SwiftlyTUIApplication.Model) -> [ToolchainViewModel] {
    if case .installList = model.screen {
        return filteredAvailableToolchains(model)
    }
    return filteredToolchains(model)
}

/// Keeps the focused row within the visible viewport.
private func adjustedListOffset(focused: Int, total: Int, viewport: Int, currentOffset: Int) -> Int {
    // Treat one line as consumed by header/divider for ScrollView height.
    let visibleRows = max(1, viewport - 2)
    guard total > visibleRows else { return 0 }
    let maxOffset = max(0, total - visibleRows)
    var offset = min(currentOffset, maxOffset)
    if focused < offset {
        offset = focused
    } else if focused >= offset + visibleRows {
        offset = focused - visibleRows + 1
    }
    return min(maxOffset, max(0, offset))
}

private func breadcrumb(for screen: SwiftlyTUIApplication.Model.Screen) -> String {
    switch screen {
    case .menu:
        return "Home"
    case .installList:
        return "Home > Install"
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
    case .error:
        return "Home > Error"
    }
}

private func hints(for screen: SwiftlyTUIApplication.Model.Screen) -> String {
    switch screen {
    case .menu:
        return "1 list/switch · 2 install · 3 uninstall · 4 update · 0/q exit"
    case .installList:
        return "j/k/arrow move · Enter install · / filter · m manual · b back · Esc clear · 0/q exit"
    case .list:
        return "j/k/arrow move · Enter/Space open · # jump · / filter · s switch · 1 refresh · b back · Esc clear · 0/q exit"
    case .detail:
        return "s switch · b back · q exit"
    case .input:
        return "Enter submit · Esc cancel · q exit"
    case .progress:
        return "Working… q exit"
    case .result:
        return "1 refresh list · b back · 0/q exit"
    case .error:
        return "r retry · c cancel · b back · 0/q exit"
    }
}

private extension SwiftlyTUIApplication {
    mutating func pushCurrentScreen() {
        model.navigationStack.append(model.screen)
    }
}
