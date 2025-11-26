import XCTest
import SwifTeaUI
@testable import Swiftly

final class RemoveFlowTests: XCTestCase {
    func testRemoveFlowCompletes() async {
        let expectationRemove = expectation(description: "remove invoked")
        let mock = MockAdapterFactory(
            list: { [] },
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
        _ = app.mapKeyToAction(.char("4")).map { app.update(action: $0) }
        app.model.input = "swift-6.0.1"
        app.update(action: .submit)
        await fulfillment(of: [expectationRemove], timeout: 1.0)

        XCTAssertEqual(app.model.lastSession?.state, .succeeded(message: "Uninstalled swift-6.0.1"))
        XCTAssertEqual(app.model.screen, .result("Uninstalled swift-6.0.1"))
    }
}
