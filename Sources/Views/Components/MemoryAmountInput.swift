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
    @State private var number: Double?

    init(amount: Binding<UInt?>) {
        _amount = amount

        if let value = amount.wrappedValue {
            if value < Scale.KB.rawValue {
                scale = .B
            } else if value >= Scale.MB.rawValue {
                scale = .MB
            }
        }
    }

    var body: some View {
        HStack {
            FloatInput<Double>(
                min: 0.0,
                max: Double(UInt.max),
                value: $number,
                formatter: .init(locale: optionsManager.locale).sign(strategy: .never)
            )

            Picker(of: Scale.allCases, selection: $scale)
        }
        .onChange(of: number, initial: false) {
            if let number, let scale {
                amount = UInt((number * Double(scale.rawValue)).rounded(.toNearestOrEven))
            } else {
                amount = nil
            }
        }
        .onChange(of: scale, initial: true) {
            if let amount, let scale {
                number = Double(amount) / Double(scale.rawValue)
            }
        }
    }
}
