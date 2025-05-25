import SwiftCrossUI

struct ErrorToast: View {
    var text: String

    var body: some View {
        ZStack {
            Color.red.opacity(0.75)

            HStack {
                Text("⚠️")
                    .font(.system(size: 48))
                    .padding()

                Text(text)
                    .padding(.trailing)
            }
        }
        .frame(width: 300)
        .cornerRadius(6)
    }
}
