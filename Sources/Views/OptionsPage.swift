import SwiftCrossUI
import Foundation

struct OptionsPage: View {
    @State var memoryImageCacheSize: UInt?
    @State var useDiskCache: Bool

    init() {
        let options = OptionsManager.shared.getOptions()
        memoryImageCacheSize = options.memoryImageCacheSize
        useDiskCache = options.useDiskCache
    }

    var body: some View {
        HStack {
            Spacer()
        
            VStack {
                Spacer()

                Text("Maximum in-memory image cache size")

                MemoryAmountInput(amount: $memoryImageCacheSize)

                Spacer()

                Toggle("Save images to disk", active: $useDiskCache)

                Spacer()

                Button("Save Changes") {
                    if let memoryImageCacheSize {
                        OptionsManager.shared.setOptions(
                            .v1(memoryImageCacheSize: memoryImageCacheSize, useDiskCache: useDiskCache)
                        )
                    }
                }
                .if(memoryImageCacheSize == nil) { $0.foregroundColor(.gray) }

                Spacer()
            }

            Spacer()
        }
    }
}