import SwiftCrossUI
import Foundation

struct LocaleWrapper: Equatable, CustomStringConvertible {
    var locale: Locale

    var description: String {
        locale.localizedString(forIdentifier: locale.identifier) ?? locale.identifier
    }
}

struct OptionsPage: View {
    @State private var memoryImageCacheSize: UInt?
    @State private var useDiskCache: Bool
    @State private var localeSelection: LocaleWrapper?
    @Binding var show: Bool

    private var localization: Localization {
        localizations[localeSelection?.locale ?? OptionsManager.shared.locale]!
    }

    init(show: Binding<Bool>) {
        _show = show

        let options = OptionsManager.shared.getOptions()
        memoryImageCacheSize = options.memoryImageCacheSize
        useDiskCache = options.useDiskCache
        localeSelection = .init(locale: options.locale)
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()

                Button(localization.uiElements.close) {
                    show = false
                }
                .padding()
            }

            Picker(
                of: localizations.keys.sorted { $0.identifier < $1.identifier }
                    .map { LocaleWrapper(locale: $0) },
                selection: $localeSelection
            )
            .padding()

            Text(localization.uiElements.maximumCache)
                .padding(.top)

            MemoryAmountInput(amount: $memoryImageCacheSize)
                .frame(width: 200)

            if let memoryImageCacheSize, memoryImageCacheSize < 630000 {
                Text(localization.uiElements.lowCacheSizeWarning).foregroundColor(.red)
                    .padding(.vertical)
                    .padding(.horizontal, 20)
            }

            Toggle(localization.uiElements.saveImages, active: $useDiskCache)
                .toggleStyle(.switch)
                .padding()

            Button(localization.uiElements.save) {
                if OptionsManager.shared.setOptions(
                    .v1(
                        memoryImageCacheSize: memoryImageCacheSize!,
                        useDiskCache: useDiskCache,
                        locale: localeSelection!.locale
                    )
                ) {
                    show = false
                }
            }
            .disabled(memoryImageCacheSize == nil || localeSelection == nil)
            .padding(.bottom, 20)
        }
    }
}
