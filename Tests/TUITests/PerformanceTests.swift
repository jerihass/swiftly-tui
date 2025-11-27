import XCTest
@testable import Swiftly

final class PerformanceTests: XCTestCase {
    func testNavigationToSwitchCompletesQuickly() async {
        let mockFactory = MockAdapterFactory(
            list: { [ToolchainFixtures.sample(active: false, id: "swift-6.0.1")] },
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
        let start = Date()
        app.update(action: .start(.list))
        app.update(action: .listLoaded([ToolchainFixtures.sample(active: false, id: "swift-6.0.1")]))
        app.update(action: .switchFocused)
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertLessThan(elapsed, 60, "Navigation to switch should take under 60 seconds")
    }

    func testProgressCadenceStaysUnderFiveSeconds() {
        let start = Date()
        let updates = (1...5).map { start.addingTimeInterval(Double($0) * 4.0) }
        XCTAssertTrue(ProgressCadence.isCadenceValid(updates: updates, maxInterval: 5.0))
    }
}
