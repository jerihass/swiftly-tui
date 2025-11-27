import XCTest
import SwifTeaUI
@testable import Swiftly

final class FocusPersistenceTests: XCTestCase {
    func testFocusPersistsAcrossDetailAndBack() {
        var app = TUITestHarness.makeApp()
        let list = [
            ToolchainFixtures.sample(active: true, id: "swift-6.0.2"),
            ToolchainFixtures.sample(active: false, id: "swift-6.0.1"),
        ]

        app.update(action: .listLoaded(list))
        XCTAssertEqual(app.model.focusedIndex, 0)

        app.update(action: .selectIndex(1))
        XCTAssertEqual(app.model.focusedIndex, 1)
        XCTAssertEqual(app.model.navigationStack.count, 1)

        app.update(action: .back)
        XCTAssertEqual(app.model.screen, .list)
        XCTAssertEqual(app.model.focusedIndex, 1, "Focused row should persist after returning from detail")
    }
}
