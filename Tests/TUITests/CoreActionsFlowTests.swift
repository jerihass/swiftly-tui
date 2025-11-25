import XCTest
@testable import Swiftly

final class CoreActionsFlowTests: XCTestCase {
    func testListToDetailToSwitchFlow() async {
        let toolchain = ToolchainFixtures.sample(active: false, id: "swift-6.0.1")
        let mockFactory = MockAdapterFactory(
            list: { [toolchain] },
            switchAction: { target in
                OperationSessionViewModel(
                    type: .switchToolchain,
                    targetIdentifier: target,
                    state: .succeeded(message: "Switched to \(target)"),
                    logPath: nil
                )
            }
        )
        var app = TUITestHarness.makeApp(adapterFactory: mockFactory)
        // Load list
        app.update(action: .start(.list))
        // Wait for async dispatch
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(app.model.screen, .list)
        XCTAssertEqual(app.model.toolchains.first?.identifier, toolchain.identifier)

        // Simulate switch
        app.update(action: .start(.switchActive))
        app.model.input = toolchain.identifier
        app.update(action: .submit)
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(app.model.lastSession?.state, .succeeded(message: "Switched to \(toolchain.identifier)"))
    }
}
