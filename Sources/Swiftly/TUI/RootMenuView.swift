import SwifTeaUI

/// Minimal placeholder menu until full SwifTeaUI flow is wired.
struct RootMenuView: TUIView {
    typealias Body = Never

    let onSelectAction: (Action) -> Void

    var body: Never { fatalError("RootMenuView has no body") }

    func render() -> String {
        """
        swiftly TUI (placeholder)
        1) List toolchains
        2) Switch toolchain
        3) Install toolchain
        4) Uninstall toolchain
        5) Update toolchain
        0) Exit
        """
    }

    enum Action {
        case list
        case switchActive
        case install
        case uninstall
        case update
        case exit
    }
}
