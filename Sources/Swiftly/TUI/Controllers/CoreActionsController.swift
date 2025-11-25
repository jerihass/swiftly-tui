import SwifTeaUI
import SwiftlyCore

final class CoreActionsController: ObservableObject {
    private let adapter: CoreActionsAdapter
    @Published var currentAction: RootMenuView.Action?
    @Published var lastOutcome: OperationOutcome?

    init(adapter: CoreActionsAdapter) {
        self.adapter = adapter
    }

    func handle(action: RootMenuView.Action) {
        currentAction = action
        // TODO: wire to TUI flows; placeholder for now.
    }
}
