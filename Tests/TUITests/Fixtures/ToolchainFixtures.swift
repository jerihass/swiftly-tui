import Foundation
@testable import Swiftly

enum ToolchainFixtures {
    static func sample(active: Bool = false, id: String = "swift-6.0.1") -> ToolchainViewModel {
        ToolchainViewModel(
            identifier: id,
            version: id,
            channel: .stable,
            location: "/tmp/\(id)",
            isActive: active,
            isInstalled: true,
            metadata: .init(
                installedAt: Date(),
                checksumVerified: true,
                sizeDescription: "1.2GB"
            )
        )
    }

    static func sampleSnapshot(id: String = "swift-DEVELOPMENT-SNAPSHOT") -> ToolchainViewModel {
        ToolchainViewModel(
            identifier: id,
            version: id,
            channel: .snapshot,
            location: "/tmp/\(id)",
            isActive: false,
            isInstalled: true,
            metadata: nil
        )
    }
}
