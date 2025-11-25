/// Handles cancel/resume flows for operations. Placeholder implementation.
final class OperationRecoveryController {
    func cancelCurrentOperation(target: String?) -> OperationSessionViewModel {
        OperationSessionViewModel(
            type: .remove,
            targetIdentifier: target,
            state: .cancelled(message: "Cancelled", logPath: nil),
            logPath: nil
        )
    }

    func retryLastOperation(_ session: OperationSessionViewModel) -> OperationSessionViewModel {
        OperationSessionViewModel(
            type: session.type,
            targetIdentifier: session.targetIdentifier,
            state: .failed(message: "Retry not implemented", logPath: session.logPath),
            logPath: session.logPath
        )
    }
}
