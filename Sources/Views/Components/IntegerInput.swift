import SwiftCrossUI
import Foundation

struct IntegerInput<T: BinaryInteger>: View {
    var placeholder = ""

    @Binding var value: T?

    var formatter: IntegerFormatStyle<T>

    @State private var text = ""

    var body: some View {
        TextField(placeholder, text: $text)
            .textContentType(.digits(ascii: false))
            .onChange(of: value, initial: true) {
                if let number = value {
                    text = formatter.format(number)
                } else {
                    text = ""
                }
            }
            .onChange(of: text, initial: false) {
                value = try? T(text, format: formatter)
            }
            .onChange(of: formatter, initial: false) {
                if let number = value {
                    text = formatter.format(number)
                } else {
                    text = ""
                }
            }
    }
}
