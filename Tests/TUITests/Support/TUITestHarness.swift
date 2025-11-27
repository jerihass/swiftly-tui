import XCTest
import SwiftlyCore
import SwifTeaUI
@testable import Swiftly

struct MockAdapterFactory: Sendable {
    var list: @Sendable () async -> [ToolchainViewModel]
    var switchAction: @Sendable (String) async -> OperationSessionViewModel
    var installAction: @Sendable (String) async -> OperationSessionViewModel = { target in
        OperationSessionViewModel(type: .install, targetIdentifier: target, state: .succeeded(message: "Installed \(target)"), logPath: nil)
    }
    var uninstallAction: @Sendable (String) async -> OperationSessionViewModel = { target in
        OperationSessionViewModel(type: .remove, targetIdentifier: target, state: .succeeded(message: "Uninstalled \(target)"), logPath: nil)
    }
    var updateAction: @Sendable (String) async -> OperationSessionViewModel = { target in
        OperationSessionViewModel(type: .update, targetIdentifier: target, state: .succeeded(message: "Updated \(target)"), logPath: nil)
    }

    func build(ctx: SwiftlyCoreContext) -> CoreActionsAdapter {
        CoreActionsAdapter(
            ctx: ctx,
            listOverride: list,
            switchOverride: switchAction,
            installOverride: installAction,
            uninstallOverride: uninstallAction,
            updateOverride: updateAction
        )
    }
}

enum TUITestHarness {
    static func makeContext() -> SwiftlyCoreContext {
        SwiftlyCoreContext()
    }

    static func makeApp(adapterFactory: MockAdapterFactory) -> SwiftlyTUIApplication {
        SwiftlyTUIApplication(
            ctx: makeContext(),
            adapterFactory: { adapterFactory.build(ctx: $0) }
        )
    }

    static func makeApp() -> SwiftlyTUIApplication {
        let mock = MockAdapterFactory(
            list: { [] },
            switchAction: { target in
                OperationSessionViewModel(
                    type: .switchToolchain,
                    targetIdentifier: target,
                    state: .succeeded(message: "Switched \(target)"),
                    logPath: nil
                )
            }
        )
        return makeApp(adapterFactory: mock)
    }

    /// Render any view in a headless 80-column context to keep layout tests predictable.
    static func render<V: TUIView>(_ view: V, width: Int = 80) -> String {
        let rendered = view.render()
        return enforceWidth(rendered, width: width)
    }

    /// Render the current app model for snapshot/layout checks.
    static func render(app: SwiftlyTUIApplication, width: Int = 80) -> String {
        render(app.view(model: app.model), width: width)
    }

    private static func enforceWidth(_ text: String, width: Int) -> String {
        text
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in
                if line.count > width {
                    let trimmed = line.prefix(width - 1)
                    return "\(trimmed)…"
                }
                return String(line)
            }
            .joined(separator: "\n")
    }
}
