import SwifTeaUI

struct ProgressViewComponent: TUIView {
    typealias Body = Never

    let title: String
    let message: String

    var body: Never { fatalError("ProgressViewComponent has no body") }

    func render() -> String {
        """
        \(title)
        \(message)
        """
    }
}
