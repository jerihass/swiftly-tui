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
        let installSession = OperationSessionViewModel(
            type: .install,
            targetIdentifier: "swift-6.0.3",
            state: .succeeded(message: "Installed swift-6.0.3"),
            logPath: "/tmp/install.log"
        )
        let mock = MockAdapterFactory(
            list: { [] },
            listAvailable: { available },
            switchAction: { _ in
                OperationSessionViewModel(type: .switchToolchain, targetIdentifier: nil, state: .succeeded(message: "ok"), logPath: nil)
            },
            installAction: { target in
                expectationInstall.fulfill()
                XCTAssertEqual(target, "swift-6.0.3")
                return installSession
            }
        )

        var app = TUITestHarness.makeApp(adapterFactory: mock)
        _ = app.mapKeyToAction(.char("2")).map { app.update(action: $0) }
        app.update(action: .availableLoaded(available))
        _ = app.mapKeyToAction(.enter).map { app.update(action: $0) }
        // Simulate dispatched session
        app.update(action: .operationSession(installSession))

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
