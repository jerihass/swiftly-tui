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
        _ = app.mapKeyToAction(.char("5")).map { app.update(action: $0) }
        app.model.input = "swift-6.0.2"
        app.update(action: .submit)
        await fulfillment(of: [expectationUpdate], timeout: 1.0)

        XCTAssertEqual(app.model.lastSession?.state, .succeeded(message: "Updated swift-6.0.2"))
        XCTAssertEqual(app.model.screen, .result("Updated swift-6.0.2"))
    }
}
