import Foundation

internal extension OperationSessionViewModel.State {
    var humanDescription: String {
        switch self {
        case .pending:
            return "pending"
        case .running(let progress, let message):
            let msg = message.map { " - \($0)" } ?? ""
            return "running \(progress)%\(msg)"
        case .succeeded(let message):
            return "success: \(message)"
        case .failed(let message, let logPath):
            let log = logPath.map { " (log: \($0))" } ?? ""
            return "failed: \(message)\(log)"
        case .cancelled(let message, let logPath):
            let msg = message ?? "cancelled"
            let log = logPath.map { " (log: \($0))" } ?? ""
            return "\(msg)\(log)"
        }
    }

    var humanErrorMessage: String {
        switch self {
        case .failed(let message, let logPath):
            let log = logPath.map { " (log: \($0))" } ?? ""
            return "Failed: \(message)\(log)"
        case .cancelled(let message, let logPath):
            let msg = message ?? "Cancelled"
            let log = logPath.map { " (log: \($0))" } ?? ""
            return "\(msg)\(log)"
        case .pending, .running, .succeeded:
            return humanDescription
        }
    }
}

internal extension OperationSessionViewModel {
    var stateDescription: String { state.humanDescription }
    var stateErrorDescription: String { state.humanErrorMessage }
}
