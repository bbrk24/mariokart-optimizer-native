import SwiftCrossUI
import Foundation

struct OptionsPage: View {
    @State private var memoryImageCacheSize: UInt?
    @State private var useDiskCache: Bool
    @Binding var show: Bool

    init(show: Binding<Bool>) {
        _show = show

        let options = OptionsManager.shared.getOptions()
        memoryImageCacheSize = options.memoryImageCacheSize
        useDiskCache = options.useDiskCache
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()

                Button("Close") {
                    show = false
                }
                .padding()
            }

            Text("Maximum in-memory image cache size")
                .padding(.top)

            MemoryAmountInput(amount: $memoryImageCacheSize)
                .frame(width: 200)

            Text(
                "Warning: reducing the image cache size too much will result in extraneous network requests and will not necessarily improve memory usage."
            )
            .foregroundColor(
                {
                    if let memoryImageCacheSize, memoryImageCacheSize < 630000 {
                        .red
                    } else {
                        .clear
                    }
                }()
            )
            .padding(.vertical)
            .padding(.horizontal, 20)

            Toggle("Save images to disk", active: $useDiskCache)
                .toggleStyle(.switch)
                .padding()

            Button("Save Changes") {
                if OptionsManager.shared.setOptions(
                    .v1(memoryImageCacheSize: memoryImageCacheSize!, useDiskCache: useDiskCache)
                ) {
                    show = false
                }
            }
            .disabled(memoryImageCacheSize == nil)
            .padding(.bottom, 20)
        }
    }
}
