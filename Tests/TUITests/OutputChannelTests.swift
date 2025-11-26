import XCTest
@testable import Swiftly

final class OutputChannelTests: XCTestCase {
    func testLogPathSurfacedInErrorState() {
        let session = OperationSessionViewModel(
            type: .install,
            targetIdentifier: "swift-err",
            state: .failed(message: "boom", logPath: "/tmp/boom.log"),
            logPath: "/tmp/boom.log"
        )
        XCTAssertTrue(session.state.humanErrorMessage.contains("/tmp/boom.log"))
    }
}
