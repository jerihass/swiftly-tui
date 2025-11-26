import XCTest
import SwifTeaUI
@testable import Swiftly

final class RecoveryFlowTests: XCTestCase {
    func testRetryFromErrorReinvokesOperation() async {
        let firstCall = expectation(description: "first install fail")
        let retryCall = expectation(description: "retry install succeeds")
        actor AttemptCounter {
            private var value = 0
            func next() -> Int { value += 1; return value }
        }
        let attempts = AttemptCounter()
        let mock = MockAdapterFactory(
            list: { [] },
            switchAction: { _ in OperationSessionViewModel(type: .switchToolchain, targetIdentifier: nil, state: .succeeded(message: "ok"), logPath: nil) },
            installAction: { target in
                let attempt = await attempts.next()
                if attempt == 1 {
                    firstCall.fulfill()
                    return OperationSessionViewModel(
                        type: .install,
                        targetIdentifier: target,
                        state: .failed(message: "boom", logPath: "/tmp/boom.log"),
                        logPath: "/tmp/boom.log"
                    )
                } else {
                    retryCall.fulfill()
                    return OperationSessionViewModel(
                        type: .install,
                        targetIdentifier: target,
                        state: .succeeded(message: "Installed \(target)"),
                        logPath: "/tmp/boom.log"
                    )
                }
            }
        )

        var app = TUITestHarness.makeApp(adapterFactory: mock)
        _ = app.mapKeyToAction(.char("3")).map { app.update(action: $0) }
        app.model.input = "swift-err"
        app.update(action: .submit)
        await fulfillment(of: [firstCall], timeout: 1.0)
        XCTAssertEqual(app.model.screen, .error(OperationSessionViewModel(type: .install, targetIdentifier: "swift-err", state: .failed(message: "boom", logPath: "/tmp/boom.log"), logPath: "/tmp/boom.log")))

        if let retry = app.mapKeyToAction(.char("r")) {
            app.update(action: retry)
        }
        await fulfillment(of: [retryCall], timeout: 1.0)
        XCTAssertEqual(app.model.lastSession?.state, .succeeded(message: "Installed swift-err"))
        XCTAssertEqual(app.model.screen, .result("Installed swift-err"))
    }

    func testCancelFromErrorReturnsToMenu() async {
        let mock = MockAdapterFactory(
            list: { [] },
            switchAction: { _ in OperationSessionViewModel(type: .switchToolchain, targetIdentifier: nil, state: .succeeded(message: "ok"), logPath: nil) },
            installAction: { target in
                OperationSessionViewModel(
                    type: .install,
                    targetIdentifier: target,
                    state: .failed(message: "boom", logPath: "/tmp/boom.log"),
                    logPath: "/tmp/boom.log"
                )
            }
        )

        var app = TUITestHarness.makeApp(adapterFactory: mock)
        _ = app.mapKeyToAction(.char("3")).map { app.update(action: $0) }
        app.model.input = "swift-err"
        app.update(action: .submit)
        XCTAssertEqual(app.model.screen, .error(OperationSessionViewModel(type: .install, targetIdentifier: "swift-err", state: .failed(message: "boom", logPath: "/tmp/boom.log"), logPath: "/tmp/boom.log")))

        if let cancel = app.mapKeyToAction(.char("c")) {
            app.update(action: cancel)
        }
        XCTAssertEqual(app.model.screen, .menu)
    }
}
