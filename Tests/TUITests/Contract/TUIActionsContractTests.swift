import XCTest
import SwifTeaUI
@testable import Swiftly

final class TUIActionsContractTests: XCTestCase {
    func testContractsMapActionsToOperationTypes() async {
        let mock = MockAdapterFactory(
            list: { [] },
            listAvailable: {
                AvailableToolchainsResult(toolchains: [
                    ToolchainViewModel(
                        identifier: "install-me",
                        version: "install-me",
                        channel: .stable,
                        location: nil,
                        isActive: false,
                        isInstalled: false,
                        metadata: nil
                    )
                ], errorMessage: nil)
            },
            switchAction: { OperationSessionViewModel(type: .switchToolchain, targetIdentifier: $0, state: .succeeded(message: "ok"), logPath: nil) },
            installAction: { OperationSessionViewModel(type: .install, targetIdentifier: $0, state: .succeeded(message: "Installed \($0)"), logPath: "/tmp/install.log") },
            uninstallAction: { OperationSessionViewModel(type: .remove, targetIdentifier: $0, state: .succeeded(message: "Uninstalled \($0)"), logPath: nil) },
            updateAction: { OperationSessionViewModel(type: .update, targetIdentifier: $0, state: .succeeded(message: "Updated \($0)"), logPath: nil) }
        )
        var app = TUITestHarness.makeApp(adapterFactory: mock)

        _ = app.mapKeyToAction(.char("2")).map { app.update(action: $0) }
        app.update(action: .availableLoaded(await mock.listAvailable()))
        _ = app.mapKeyToAction(.enter).map { app.update(action: $0) }
        app.update(action: .operationSession(await mock.installAction("install-me")))
        XCTAssertEqual(app.model.lastSession?.type, .install)

        let updateToolchain = ToolchainFixtures.sample(id: "update-me")
        app.model.toolchains = [updateToolchain]
        app.model.screen = .detail(updateToolchain)
        if let action = app.mapKeyToAction(.char("p")) {
            app.update(action: action)
        }
        app.update(action: .operationSession(await mock.updateAction(updateToolchain.identifier)))
        XCTAssertEqual(app.model.lastSession?.type, .update)

        let removeToolchain = ToolchainFixtures.sample(id: "remove-me")
        app.model.toolchains = [removeToolchain]
        app.model.screen = .detail(removeToolchain)
        if let action = app.mapKeyToAction(.char("u")) {
            app.update(action: action)
        }
        app.update(action: .operationSession(await mock.uninstallAction(removeToolchain.identifier)))
        XCTAssertEqual(app.model.lastSession?.type, .remove)
    }
}
