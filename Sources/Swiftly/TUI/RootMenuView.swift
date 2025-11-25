import SwifTeaUI

struct RootMenuView: View {
    let onSelectAction: (Action) -> Void

    var body: some View {
        VStack {
            Text("swiftly TUI")
                .font(.title)
            Text("Use arrows/Tab to navigate; Enter to select.")
                .font(.footnote)
            List {
                Button("List toolchains") { onSelectAction(.list) }
                Button("Switch toolchain") { onSelectAction(.switchActive) }
                Button("Install toolchain") { onSelectAction(.install) }
                Button("Uninstall toolchain") { onSelectAction(.uninstall) }
                Button("Update toolchain") { onSelectAction(.update) }
                Button("Exit") { onSelectAction(.exit) }
            }
        }
        .padding()
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
