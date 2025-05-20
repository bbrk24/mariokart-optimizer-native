import SwiftCrossUI
import Foundation

struct FloatInput<T: BinaryFloatingPoint>: View {
    var placeholder: String
    var min: T
    var max: T

    @Binding var value: T?

    var formatter: FloatingPointFormatStyle<T>

    @State private var text = ""

    init(
        placeholder: String = "",
        min: T = -.infinity,
        max: T = .infinity,
        value: Binding<T?>,
        formatter: FloatingPointFormatStyle<T>
    ) {
        precondition(min <= max)
        self.placeholder = placeholder
        self.min = min
        self.max = max
        self._value = value
        self.formatter = formatter
    }

    var body: some View {
        TextField(placeholder, text: $text)
            .textContentType(.decimal(signed: min < .zero))
            .onChange(of: min, initial: false) {
                value = value.map { Swift.max(self.min, Swift.min($0, self.max)) }
            }
            .onChange(of: max, initial: false) {
                value = value.map { Swift.max(self.min, Swift.min($0, self.max)) }
            }
            .onChange(of: value, initial: true) {
                if let number = value {
                    text = formatter.format(number)
                } else {
                    text = ""
                }
            }
            .onChange(of: text, initial: false) {
                value = (try? T(text, format: formatter))
                    .map {
                        if $0 < min {
                            text = formatter.format(min)
                            return min
                        } else if $0 > max {
                            text = formatter.format(max)
                            return max
                        }
                        return $0
                    }
            }
    }
}
