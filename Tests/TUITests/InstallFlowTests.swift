import XCTest
import SwifTeaUI
@testable import Swiftly

final class InstallFlowTests: XCTestCase {
    func testInstallFlowCompletesWithSuccessMessage() async {
        let expectationInstall = expectation(description: "install invoked")
        let available = AvailableToolchainsResult(toolchains: [
            ToolchainViewModel(
                identifier: "swift-6.0.3",
                version: "swift-6.0.3",
                channel: .stable,
                location: nil,
                isActive: false,
                isInstalled: false,
                metadata: nil
            )
        ], errorMessage: nil)
        let mock = MockAdapterFactory(
            list: { [] },
            listAvailable: { available },
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
        app.update(action: .availableLoaded(available))
        _ = app.mapKeyToAction(.enter).map { app.update(action: $0) }
        // Simulate dispatched session
        let session = await mock.installAction("swift-6.0.3")
        app.update(action: .operationSession(session))

        await fulfillment(of: [expectationInstall], timeout: 1.0)
        XCTAssertEqual(app.model.lastSession?.state, .succeeded(message: "Installed swift-6.0.3"))
        XCTAssertEqual(app.model.screen, .result("Installed swift-6.0.3"))
    }

    func testInstallRejectsInvalidIdentifier() {
        var app = TUITestHarness.makeApp()
        _ = app.mapKeyToAction(.char("2")).map { app.update(action: $0) }
        app.update(action: .availableLoaded(AvailableToolchainsResult(toolchains: [], errorMessage: nil)))
        _ = app.mapKeyToAction(.char("m")).map { app.update(action: $0) }
        app.model.input = "???"
        app.update(action: .submit)
        XCTAssertTrue(app.model.message.contains("Invalid identifier"))
        XCTAssertEqual(app.model.screen, .input(.install))
    }
}
