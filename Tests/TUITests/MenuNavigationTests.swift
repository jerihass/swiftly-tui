import XCTest
import SwifTeaUI
@testable import Swiftly

final class MenuNavigationTests: XCTestCase {
    func testMenuSelectionTriggersListLoad() async {
        let expectationList = expectation(description: "list loaded")
        let mockFactory = MockAdapterFactory(
            list: {
                expectationList.fulfill()
                return [ToolchainFixtures.sample(active: true)]
            },
            switchAction: { target in
                OperationSessionViewModel(
                    type: .switchToolchain,
                    targetIdentifier: target,
                    state: .succeeded(message: "Switched"),
                    logPath: nil
                )
            }
        )
        var app = TUITestHarness.makeApp(adapterFactory: mockFactory)
        if let action = app.mapKeyToAction(.char("1")) {
            app.update(action: action)
        }
        await fulfillment(of: [expectationList], timeout: 1.0)
        XCTAssertEqual(app.model.screen, .list)
        XCTAssertFalse(app.model.toolchains.isEmpty)
    }
}
