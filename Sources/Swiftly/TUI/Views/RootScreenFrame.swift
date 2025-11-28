import Foundation
import SwifTeaUI

typealias ToolchainRow = (offset: Int, element: ToolchainViewModel)

struct RootTUIView: TUIView {
    typealias Body = Never
    let model: SwiftlyTUIApplication.Model
    let overlay: OverlayPresenter
    let theme: SwifTeaTheme

    var body: Never { fatalError("RootTUIView has no body") }

    func render() -> String {
        OverlayHost(presenter: overlay) {
            ScreenFrame(model: model, theme: theme)
        }.render()
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
                    Text(headerLabel(for: model.screen))
                        .foregroundColor(theme.accent)
                        .bold()
                    Text(model.message)
                        .foregroundColor(theme.primaryText)
                    bodyContent()
                    statusBar()
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
                Text("0) Exit")
                menuStatsView()
            }
        case .progress(let message):
            let running = model.lastSession
            return VStack(spacing: 1, alignment: .leading) {
                if let state = running?.state, case .running(let percent, let detail) = state {
                    Spinner(label: detail ?? message, style: .braille, color: theme.accent, isBold: true)
                    ProgressMeter(
                        value: Double(percent) / 100.0,
                        width: 24,
                        style: .tinted(theme.accent),
                        showsPercentage: true
                    )
                } else {
                    Spinner(label: message, style: .braille, color: theme.accent, isBold: true)
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
                if let meta = toolchain.metadata?.sizeDescription { Text("Size: \(meta)") .foregroundColor(theme.mutedText) }
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
                let validation = validationMessage(for: type)
                return VStack(spacing: 1, alignment: .leading) {
                    EmptyHeader()
                    Text("Install - enter toolchain identifier (blank = latest stable):")
                    Text("> \(model.input)")
                    if let validation {
                        Text(validation).foregroundColor(.red)
                    }
                }
            default:
                return VStack(spacing: 1, alignment: .leading) { Text(AccessibilityStyles.focusIndicator(for: model.input)) }
            }
        }
    }

    private func validationMessage(for type: SwiftlyTUIApplication.ActionType) -> String? {
        let defaults: [SwiftlyTUIApplication.ActionType: String] = [
            .install: "Enter toolchain identifier for install:",
        ]
        guard let expected = defaults[type] else { return nil }
        let current = model.message
        if current == expected { return nil }
        if current.hasPrefix("Enter toolchain identifier") { return nil } // still prompt-like
        return current
    }

    // MARK: - Status rendering helpers inside frame
    private func statusBar() -> any TUIView {
        StatusBar(
            leading: [
                StatusBar.Segment("Path: \(statusPath(for: model.screen))", color: theme.primaryText),
                StatusBar.Segment(statusExitHint(), color: theme.mutedText)
            ],
            trailing: [
                StatusBar.Segment(trimmed(KeyboardHints.description(for: hintContext(for: model.screen)), to: 76), color: theme.mutedText)
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

    private func headerLabel(for screen: SwiftlyTUIApplication.Model.Screen) -> String {
        switch screen {
        case .menu: return "Main menu"
        case .list: return "Installed toolchains"
        case .installList: return "Install toolchains"
        case .detail: return "Toolchain details"
        case .input(let type): return "\(type.rawValue) input"
        case .progress: return "Working"
        case .result: return "Result"
        case .error: return "Action error"
        }
    }

    /// Truncate text to a fixed width with a trailing ellipsis when needed.
    private func trimmed(_ text: String, to maxLength: Int) -> String {
        guard text.count > maxLength, maxLength > 3 else { return text }
        let endIndex = text.index(text.startIndex, offsetBy: maxLength - 3)
        return text[text.startIndex..<endIndex] + "..."
    }

    private func statusPath(for screen: SwiftlyTUIApplication.Model.Screen) -> String {
        headerLabel(for: screen)
    }

    private func statusExitHint() -> String {
        "exit (0/q)"
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

private extension ScreenFrame {
    func menuStatsView() -> some TUIView {
        let installedCount = model.toolchains.count
        let newestInstall = latestInstallDate()
        let newestText = formattedDate(newestInstall)
        let xcodeInstalled = model.toolchains.contains { $0.identifier == "xcode" }
        let xcodeText = xcodeInstalled ? "installed" : "not installed"
        return VStack(spacing: 0, alignment: .leading) {
            Text("Installed toolchains: \(installedCount)")
                .foregroundColor(theme.primaryText)
            Text("Newest install: \(newestText)")
                .foregroundColor(theme.mutedText)
            Text("Xcode toolchain: \(xcodeText)")
                .foregroundColor(xcodeInstalled ? theme.success : theme.mutedText)
        }
        .padding(1)
        .border(padding: 1, color: theme.frameBorder, bold: false)
    }

    private func latestInstallDate() -> Date? {
        model.toolchains.compactMap { $0.metadata?.installedAt }.max()
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "unknown" }
        return Self.statsDateFormatter.string(from: date)
    }

    private static let statsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
