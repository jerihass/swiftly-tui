import XCTest
import SwifTeaUI
@testable import Swiftly

final class TUIActionsContractTests: XCTestCase {
    func testContractsMapActionsToOperationTypes() async {
        let mock = MockAdapterFactory(
            list: { [] },
            switchAction: { OperationSessionViewModel(type: .switchToolchain, targetIdentifier: $0, state: .succeeded(message: "ok"), logPath: nil) },
            installAction: { OperationSessionViewModel(type: .install, targetIdentifier: $0, state: .succeeded(message: "Installed \($0)"), logPath: "/tmp/install.log") },
            uninstallAction: { OperationSessionViewModel(type: .remove, targetIdentifier: $0, state: .succeeded(message: "Uninstalled \($0)"), logPath: nil) },
            updateAction: { OperationSessionViewModel(type: .update, targetIdentifier: $0, state: .succeeded(message: "Updated \($0)"), logPath: nil) }
        )
        var app = TUITestHarness.makeApp(adapterFactory: mock)

        _ = app.mapKeyToAction(.char("3")).map { app.update(action: $0) }
        app.model.input = "install-me"
        app.update(action: .operationSession(await mock.installAction("install-me")))
        XCTAssertEqual(app.model.lastSession?.type, .install)

        _ = app.mapKeyToAction(.char("5")).map { app.update(action: $0) }
        app.model.input = "update-me"
        app.update(action: .operationSession(await mock.updateAction("update-me")))
        XCTAssertEqual(app.model.lastSession?.type, .update)

        _ = app.mapKeyToAction(.char("4")).map { app.update(action: $0) }
        app.model.input = "remove-me"
        app.update(action: .operationSession(await mock.uninstallAction("remove-me")))
        XCTAssertEqual(app.model.lastSession?.type, .remove)
    }
}
