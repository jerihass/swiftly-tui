import SwifTeaUI

struct ProgressViewComponent: View {
    let title: String
    let message: String

    var body: some View {
        VStack {
            Text(title).font(.headline)
            Text(message).font(.footnote)
        }
        .padding()
    }
}
