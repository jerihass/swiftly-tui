import SwiftlyCore

/// Placeholder controller to be replaced with real SwifTeaUI wiring.
final class CoreActionsController {
    private let adapter: CoreActionsAdapter
    var currentAction: RootMenuView.Action?
    var lastOutcome: OperationOutcome?

    init(adapter: CoreActionsAdapter) {
        self.adapter = adapter
    }

    func handle(action: RootMenuView.Action) {
        currentAction = action
        // TODO: wire to TUI flows; placeholder for now.
        switch action {
        case .list:
            lastOutcome = OperationOutcome(action: "list", targetToolchainId: "", status: .success, message: "Not implemented")
        case .switchActive:
            lastOutcome = OperationOutcome(action: "switch", targetToolchainId: "", status: .failed, message: "Not implemented")
        case .install:
            lastOutcome = OperationOutcome(action: "install", targetToolchainId: "", status: .failed, message: "Not implemented")
        case .uninstall:
            lastOutcome = OperationOutcome(action: "uninstall", targetToolchainId: "", status: .failed, message: "Not implemented")
        case .update:
            lastOutcome = OperationOutcome(action: "update", targetToolchainId: "", status: .failed, message: "Not implemented")
        case .exit:
            break
        }
    }
}
