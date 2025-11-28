import XCTest
import SwifTeaUI
@testable import Swiftly

final class RemoveFlowTests: XCTestCase {
    func testDetailUninstallTriggersAdapter() async {
        let expectationRemove = expectation(description: "remove invoked")
        let toolchain = ToolchainFixtures.sample(id: "swift-6.0.1")
        let mock = MockAdapterFactory(
            list: { [toolchain] },
            switchAction: { _ in OperationSessionViewModel(type: .switchToolchain, targetIdentifier: nil, state: .succeeded(message: "ok"), logPath: nil) },
            uninstallAction: { target in
                expectationRemove.fulfill()
                return OperationSessionViewModel(
                    type: .remove,
                    targetIdentifier: target,
                    state: .succeeded(message: "Uninstalled \(target)"),
                    logPath: nil
                )
            }
        )

        var app = TUITestHarness.makeApp(adapterFactory: mock)
        app.model.toolchains = [toolchain]
        app.model.screen = .detail(toolchain)
        if let action = app.mapKeyToAction(.char("u")) {
            app.update(action: action)
        }

        let session = await mock.uninstallAction(toolchain.identifier)
        app.update(action: .operationSession(session))
        await fulfillment(of: [expectationRemove], timeout: 1.0)

        XCTAssertEqual(app.model.lastSession?.state, .succeeded(message: "Uninstalled swift-6.0.1"))
        XCTAssertEqual(app.model.screen, .result("Uninstalled swift-6.0.1"))
    }
}
