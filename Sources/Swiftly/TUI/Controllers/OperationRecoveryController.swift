import SwiftlyCore

/// Handles cancel/resume flows for operations.
struct OperationRecoveryController {
    let ctx: SwiftlyCoreContext
    let controller: CoreActionsController

    init(ctx: SwiftlyCoreContext, controller: CoreActionsController) {
        self.ctx = ctx
        self.controller = controller
    }

    func cancelCurrentOperation(target: String?) -> OperationSessionViewModel {
        OperationSessionViewModel(
            type: .detail,
            targetIdentifier: target,
            state: .cancelled(message: "Cancelled", logPath: nil),
            logPath: nil
        )
    }

    func retryLastOperation(
        _ session: OperationSessionViewModel,
        onProgressLog: @Sendable @escaping (String) -> Void = { _ in }
    ) async -> OperationSessionViewModel {
        switch session.type {
        case .install:
            return await controller.install(id: session.targetIdentifier ?? "", onProgressLog: onProgressLog)
        case .update:
            return await controller.update(id: session.targetIdentifier ?? "", onProgressLog: onProgressLog)
        case .remove:
            guard let target = session.targetIdentifier else {
            return cancelledFallback(session)
            }
            return await controller.remove(id: target)
        case .switchToolchain:
            guard let target = session.targetIdentifier else {
                return cancelledFallback(session)
            }
            return await controller.switchToolchain(id: target)
        case .list, .detail:
            return cancelledFallback(session)
        }
    }

    private func cancelledFallback(_ session: OperationSessionViewModel) -> OperationSessionViewModel {
        OperationSessionViewModel(
            type: session.type,
            targetIdentifier: session.targetIdentifier,
            state: .cancelled(message: "No target to retry", logPath: session.logPath),
            logPath: session.logPath
        )
    }
}
