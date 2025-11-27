import SwifTeaUI

struct UpdateView: TUIView {
    typealias Body = Never
    let header: any TUIView
    let input: String
    let validation: String?

    var body: Never { fatalError("UpdateView has no body") }

    func render() -> String {
        VStack(spacing: 1, alignment: .leading) {
            header
            Text("Update - enter toolchain identifier (blank = in-use):")
            Text("> \(input)")
            if let validation {
                Text(validation).foregroundColor(.red)
            }
        }.render()
    }
}
