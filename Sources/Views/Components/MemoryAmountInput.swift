import SwiftCrossUI

enum Scale: UInt, CaseIterable, CustomStringConvertible {
    case B = 1
    case KB = 1_000
    case MB = 1_000_000

    var description: String {
        let localization = localizations[OptionsManager.shared.locale]!

        switch self {
        case .B:
            return localization.uiElements.bytes
        case .KB:
            return localization.uiElements.kb
        case .MB:
            return localization.uiElements.mb
        }
    }
}

struct MemoryAmountInput: View {
    @State private var optionsManager = OptionsManager.shared
    @Binding var amount: UInt?
    @State private var scale: Scale? = .KB
    @State private var number: UInt?

    init(amount: Binding<UInt?>) {
        _amount = amount

        if let value = amount.wrappedValue {
            if value < 10 * Scale.KB.rawValue {
                scale = .B
            } else if value >= 10 * Scale.MB.rawValue {
                scale = .MB
            }
        }
    }

    var body: some View {
        HStack {
            IntegerInput<UInt>(
                value: $number,
                formatter: .init(locale: optionsManager.locale).sign(strategy: .never)
            )

            Picker(of: Scale.allCases, selection: $scale)
        }
        .onChange(of: number, initial: false) {
            if let number, let scale {
                amount = number * scale.rawValue
            } else {
                amount = nil
            }
        }
        .onChange(of: scale, initial: true) {
            if let amount, let scale {
                number = amount / scale.rawValue
            }
        }
    }
}
