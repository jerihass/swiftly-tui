import XCTest
import SwiftlyCore
import SwifTeaUI
@testable import Swiftly

struct MockAdapterFactory: Sendable {
    var list: @Sendable () async -> [ToolchainViewModel]
    var switchAction: @Sendable (String) async -> OperationSessionViewModel

    func build(ctx: SwiftlyCoreContext) -> CoreActionsAdapter {
        CoreActionsAdapter(
            ctx: ctx,
            listOverride: list,
            switchOverride: switchAction
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
}
