import XCTest
import SwifTeaUI
@testable import Swiftly

final class InstallFlowTests: XCTestCase {
    func testInstallFlowCompletesWithSuccessMessage() async {
        let expectationInstall = expectation(description: "install invoked")
        let mock = MockAdapterFactory(
            list: { [] },
            switchAction: { _ in OperationSessionViewModel(type: .switchToolchain, targetIdentifier: nil, state: .succeeded(message: "ok"), logPath: nil) },
            installAction: { target in
                expectationInstall.fulfill()
                return OperationSessionViewModel(
                    type: .install,
                    targetIdentifier: target,
                    state: .succeeded(message: "Installed \(target)"),
                    logPath: "/tmp/install.log"
                )
            }
        )

        var app = TUITestHarness.makeApp(adapterFactory: mock)
        _ = app.mapKeyToAction(.char("2")).map { app.update(action: $0) }
        app.model.input = "swift-6.0.3"
        // Simulate dispatched session
        let session = await mock.installAction("swift-6.0.3")
        app.update(action: .operationSession(session))

        await fulfillment(of: [expectationInstall], timeout: 1.0)
        XCTAssertEqual(app.model.lastSession?.state, .succeeded(message: "Installed swift-6.0.3"))
        XCTAssertEqual(app.model.screen, .result("Installed swift-6.0.3"))
    }

    func testRemoveRequiresIdentifier() {
        var app = TUITestHarness.makeApp()
        _ = app.mapKeyToAction(.char("3")).map { app.update(action: $0) }
        app.model.input = "   "
        app.update(action: .submit)
        XCTAssertEqual(app.model.message, "Input cannot be empty.")
        XCTAssertEqual(app.model.screen, .input(.uninstall))
    }

    func testInstallRejectsInvalidIdentifier() {
        var app = TUITestHarness.makeApp()
        _ = app.mapKeyToAction(.char("2")).map { app.update(action: $0) }
        app.model.input = "???"
        app.update(action: .submit)
        XCTAssertTrue(app.model.message.contains("Invalid identifier"))
        XCTAssertEqual(app.model.screen, .input(.install))
    }
}
