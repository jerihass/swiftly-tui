import Foundation

struct ToolchainSummary {
    let id: String
    let name: String
    let version: String
    let channel: String
    let status: String
}

struct OperationOutcome {
    enum OutcomeStatus {
        case success
        case failed
        case cancelled
    }

    let action: String
    let targetToolchainId: String
    let status: OutcomeStatus
    let message: String
}

struct OperationState {
    enum Status {
        case pending
        case inProgress(Double?)
        case success(OperationOutcome)
        case failure(OperationOutcome)
        case cancelled(OperationOutcome?)
    }

    let action: String
    let targetId: String
    var status: Status
    let startedAt: Date
}
