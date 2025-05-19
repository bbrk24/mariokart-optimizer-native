import SwiftCrossUI
import ImageFormats
import Foundation
import Alamofire

struct RemoteImage: View {
    @State private var image: ImageFormats.Image<RGBA>?
    @State private var loading = true

    var src: String

    var body: some View {
        Group {
            if let image {
                SwiftCrossUI.Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 64, maxHeight: 64)
            } else if !loading {
                Text(src.components(separatedBy: ".")[0])
            } else {
                ProgressView()
                    .task {
                        for await image in ImageManager.shared.startLoading(imageName: src) {
                            self.image = image
                        }
                        loading = false
                    }
            }
        }
        .onChange(of: src, initial: false) {
            loading = true
            image = nil
        }
    }
}
