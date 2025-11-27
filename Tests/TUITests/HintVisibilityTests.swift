import XCTest
import SwifTeaUI
@testable import Swiftly

final class HintVisibilityTests: XCTestCase {
    func testHintsMatchBindingsPerScreen() {
        var app = TUITestHarness.makeApp()
        let cases: [(SwiftlyTUIApplication.Model.Screen, KeyboardHints.Context, () -> Void)] = [
            (.menu, .menu, { app.model.navigationStack = [] }),
            (.list, .list, {
                app.model.toolchains = [ToolchainFixtures.sample(active: true, id: "swift-6.0.2")]
            }),
            (.detail(ToolchainFixtures.sample(active: true, id: "swift-6.0.2")), .detail, {}),
            (.input(.install), .input, {}),
            (.progress("Working"), .progress, {}),
            (.result("Done"), .result, {}),
            (.error(OperationSessionViewModel(type: .install, targetIdentifier: "swift-6.0.2", state: .failed(message: "boom", logPath: "/tmp/log"), logPath: "/tmp/log")), .error, {})
        ]

        for (screen, ctx, prepare) in cases {
            prepare()
            app.model.screen = screen
            let rendered = TUITestHarness.render(app: app)
            let expected = KeyboardHints.description(for: ctx)
            let snippet = String(expected.prefix(15))
            XCTAssertTrue(rendered.contains(snippet), "Hints should match bindings for \(screen)")
        }
    }
}
