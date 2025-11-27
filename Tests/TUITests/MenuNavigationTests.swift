import XCTest
import SwifTeaUI
@testable import Swiftly

final class MenuNavigationTests: XCTestCase {
    func testMenuSelectionTriggersListLoad() async {
        let mockFactory = MockAdapterFactory(
            list: { [ToolchainFixtures.sample(active: true)] },
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
        app.update(action: .listLoaded(await mockFactory.list()))
        XCTAssertEqual(app.model.screen, .list)
        XCTAssertFalse(app.model.toolchains.isEmpty)
    }
}
