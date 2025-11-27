import XCTest
import SwifTeaUI
@testable import Swiftly

final class MenuActionsTests: XCTestCase {
    func testMenuKeysMapToAllCoreActions() {
        var app = TUITestHarness.makeApp()
        app.model.screen = .menu

        assertStart(.list, for: app.mapKeyToAction(.char("1")))
        assertStart(.install, for: app.mapKeyToAction(.char("2")))
        assertStart(.uninstall, for: app.mapKeyToAction(.char("3")))
        assertStart(.update, for: app.mapKeyToAction(.char("4")))
        assertExit(app.mapKeyToAction(.char("0")))
        assertExit(app.mapKeyToAction(.char("q")))
    }

    private func assertStart(_ type: SwiftlyTUIApplication.ActionType, for action: SwiftlyTUIApplication.Action?, file: StaticString = #filePath, line: UInt = #line) {
        guard case .start(let actualType)? = action else {
            return XCTFail("Expected start action for \(String(describing: action))", file: file, line: line)
        }
        XCTAssertEqual(actualType, type, file: file, line: line)
    }

    private func assertExit(_ action: SwiftlyTUIApplication.Action?, file: StaticString = #filePath, line: UInt = #line) {
        guard case .exit? = action else {
            return XCTFail("Expected exit action for \(String(describing: action))", file: file, line: line)
        }
    }
}
