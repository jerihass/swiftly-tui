import Foundation

struct OperationSessionViewModel: Equatable {
    enum OperationType {
        case list
        case detail
        case switchToolchain
        case install
        case update
        case remove
    }

    enum State: Equatable {
        case pending
        case running(progress: Int, message: String?)
        case succeeded(message: String)
        case failed(message: String, logPath: String?)
        case cancelled(message: String?, logPath: String?)
    }

    let type: OperationType
    let targetIdentifier: String?
    var state: State
    var logPath: String?
}
