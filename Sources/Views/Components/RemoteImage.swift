import SwiftCrossUI
import ImageFormats
import Foundation
import Alamofire

@MainActor
struct RemoteImage: @preconcurrency View {
    @State private var image: ImageFormats.Image<RGBA>?
    @State private var loading = true

    var src: String

    var body: some View {
        Group {
            if let image {
                SwiftCrossUI.Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
            } else if !loading {
                Text(src.components(separatedBy: ".")[0])
            } else {
                ProgressView()
                    .task { @Sendable in
                        for await image in ImageManager.shared.startLoading(imageName: src) {
                            await MainActor.run {
                                self.image = image
                            }
                        }

                        await MainActor.run {
                            loading = false
                        }
                    }
            }
        }
        .onChange(of: src, initial: false) {
            loading = true
            image = nil
        }
    }
}
