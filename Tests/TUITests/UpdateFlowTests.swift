import XCTest
import SwifTeaUI
@testable import Swiftly

final class UpdateFlowTests: XCTestCase {
    func testUpdateFlowShowsCompletion() async {
        let expectationUpdate = expectation(description: "update invoked")
        let mock = MockAdapterFactory(
            list: { [] },
            switchAction: { _ in OperationSessionViewModel(type: .switchToolchain, targetIdentifier: nil, state: .succeeded(message: "ok"), logPath: nil) },
            updateAction: { target in
                expectationUpdate.fulfill()
                return OperationSessionViewModel(
                    type: .update,
                    targetIdentifier: target,
                    state: .succeeded(message: "Updated \(target)"),
                    logPath: nil
                )
            }
        )

        var app = TUITestHarness.makeApp(adapterFactory: mock)
        let toolchain = ToolchainFixtures.sample(id: "swift-6.0.2")
        app.model.toolchains = [toolchain]
        app.model.screen = .detail(toolchain)
        if let action = app.mapKeyToAction(.char("p")) {
            app.update(action: action)
        }
        let session = await mock.updateAction(toolchain.identifier)
        app.update(action: .operationSession(session))
        await fulfillment(of: [expectationUpdate], timeout: 1.0)

        XCTAssertEqual(app.model.lastSession?.state, .succeeded(message: "Updated swift-6.0.2"))
        XCTAssertEqual(app.model.screen, .result("Updated swift-6.0.2"))
    }
}
