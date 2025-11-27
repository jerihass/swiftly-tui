import XCTest
@testable import Swiftly

final class ListingViewTests: XCTestCase {
    func testListRendersActiveFirst() {
        let toolchains = ListLayoutAdapter.sort([
            ToolchainFixtures.sample(active: false, id: "swift-6.0.1"),
            ToolchainFixtures.sample(active: true, id: "swift-6.0.2"),
        ])

        let view = ToolchainListView(toolchains: toolchains)
        let rendered = view.render()

        XCTAssertTrue(rendered.split(separator: "\n").first?.contains("swift-6.0.2") == true)
    }

    func testEmptyStateShowsGuidance() {
        let view = ToolchainListView(toolchains: [])
        let rendered = view.render()
        XCTAssertTrue(rendered.contains("No toolchains installed"), "Empty state should guide install flow")
        XCTAssertTrue(rendered.contains("Install (2)"), "Empty state should point to install action")
    }
}
