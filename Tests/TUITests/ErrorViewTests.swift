import XCTest
import SwifTeaUI
@testable import Swiftly

final class ErrorViewTests: XCTestCase {
    func testErrorViewDisplaysMessageLogAndOptions() {
        let view = ErrorView(
            message: "Failed: boom",
            suggestion: "Retry or cancel",
            logPath: "/tmp/log.jsonl"
        )
        let rendered = view.render()
        XCTAssertTrue(rendered.contains("Failed: boom"))
        XCTAssertTrue(rendered.contains("Log: /tmp/log.jsonl"))
        XCTAssertTrue(rendered.contains("Options: r retry"))
    }
}
