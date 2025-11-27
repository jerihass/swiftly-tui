import SwifTeaUI

struct InstallView: TUIView {
    typealias Body = Never
    let header: any TUIView
    let input: String
    let validation: String?

    var body: Never { fatalError("InstallView has no body") }

    func render() -> String {
        VStack(spacing: 1, alignment: .leading) {
            header
            Text("Install - enter toolchain identifier (blank = latest stable):")
            Text("> \(input)")
            if let validation {
                Text(validation).foregroundColor(.red)
            }
        }.render()
    }
}
