import SwiftCrossUI
import Foundation
import ImageFormats
import Alamofire

struct ImageManager {
    static let queue = RequestQueue<String, AFDataResponse<Data>, Never>()
    static let baseUrl = URL(string: "https://bbrk24.github.io/mariokart-optimizer/img/")!

    private init() {}
    static let shared = ImageManager()

    func startLoading(imageName: String) -> some AsyncSequence<ImageFormats.Image<RGBA>, Never> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            var lastModified: Date? = nil
            var expires: Date? = nil
            if let t = ImageCache.shared.getImage(name: imageName) {
                continuation.yield(t.image)
                lastModified = t.lastModified
                expires = t.expires
            }

            if let expires, expires > .now {
                continuation.finish()         
                return
            }

            Task { [lastModified] in
                defer { continuation.finish() }

                let result = await ImageManager.queue.addOrWait(id: imageName) {
                    await DataRequester().getData(
                        url: ImageManager.baseUrl.appending(path: imageName),
                        accept: "image/png, image/webp, image/jpeg;q=0.8",
                        ifModifiedSince: lastModified
                    )
                }

                if
                    let data = result.data,
                    let response = result.response,
                    response.statusCode == 200
                {
                    var expires: Date? = nil
                    if let expiresHeader = response.headers["expires"] {
                        expires = DataRequester.headerDateFormatter.date(from: expiresHeader)
                    }

                    if let newImage = ImageCache.shared.addImage(rawBytes: data, name: imageName, expires: expires) {
                        continuation.yield(newImage)
                    }
                }

                if let error = result.error {
                    print(error)
                }
            }
        }
    }
}