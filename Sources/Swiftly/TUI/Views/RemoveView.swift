import SwifTeaUI

struct RemoveView: TUIView {
    typealias Body = Never
    let header: any TUIView
    let input: String

    var body: Never { fatalError("RemoveView has no body") }

    func render() -> String {
        VStack(spacing: 1, alignment: .leading) {
            header
            Text("Remove - enter toolchain identifier:")
            Text("> \(input)")
        }.render()
    }
}
