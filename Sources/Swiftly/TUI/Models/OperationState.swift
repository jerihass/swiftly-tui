import Foundation

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
