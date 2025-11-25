import Foundation

struct ToolchainViewModel: Equatable {
    enum Channel: String {
        case stable
        case snapshot
    }

    let identifier: String
    let version: String
    let channel: Channel
    let location: String?
    let isActive: Bool
    let isInstalled: Bool
    let metadata: Metadata?

    struct Metadata: Equatable {
        let installedAt: Date?
        let checksumVerified: Bool?
        let sizeDescription: String?
    }
}
