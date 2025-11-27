import XCTest
import SwifTeaUI
@testable import Swiftly

final class LayoutConsistencyTests: XCTestCase {
    func testHeaderAndStatusPresentAcrossScreens() {
        var app = TUITestHarness.makeApp()
        let screens: [SwiftlyTUIApplication.Model.Screen] = [
            .menu,
            .list,
            .detail(ToolchainFixtures.sample(active: true, id: "swift-6.0.2")),
            .input(.install),
            .progress("Working"),
            .result("Done"),
            .error(OperationSessionViewModel(type: .install, targetIdentifier: "swift-6.0.2", state: .failed(message: "boom", logPath: "/tmp/log"), logPath: "/tmp/log"))
        ]

        for screen in screens {
            app.model.screen = screen
            if case .list = screen {
                app.model.toolchains = [
                    ToolchainFixtures.sample(active: true, id: "swift-6.0.2"),
                    ToolchainFixtures.sample(active: false, id: "swift-6.0.1"),
                ]
            }
            let rendered = TUITestHarness.render(app: app)
            XCTAssertTrue(rendered.contains("swiftly TUI"), "Header should be present for \(screen)")
            XCTAssertTrue(rendered.contains("Path:"), "Status bar should include breadcrumb for \(screen)")
            XCTAssertTrue(rendered.contains("exit"), "Status bar should include keyboard hints for \(screen)")
        }
    }
}
