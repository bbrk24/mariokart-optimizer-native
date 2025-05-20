import Alamofire
import Foundation
import ImageFormats
import Semaphore
import SwiftCrossUI

struct ImageManager {
    static let queue = RequestQueue<String, AFDataResponse<Data>, Never>()
    static let baseUrl = URL(string: "https://bbrk24.github.io/mariokart-optimizer/img/")!
    static let concurrentRequestLimit = 6

    private let semaphore = AsyncSemaphore(value: concurrentRequestLimit)

    private init() {}
    static let shared = ImageManager()

    func startLoading(imageName: String) -> some AsyncSequence<ImageFormats.Image<RGBA>, Never> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            Task {
                await semaphore.wait()
                defer {
                    continuation.finish()
                    semaphore.signal()
                }

                var lastModified: Date? = nil
                if let t = ImageCache.shared.getImage(name: imageName) {
                    continuation.yield(t.image)
                    lastModified = t.lastModified

                    if let expires = t.expires, expires > .now {
                        continuation.finish()
                        return
                    }
                }

                let result = await ImageManager.queue.addOrWait(id: imageName) { [lastModified] in
                    await DataRequester()
                        .getData(
                            url: ImageManager.baseUrl.appending(path: imageName),
                            accept: "image/png, image/webp, image/jpeg;q=0.75",
                            ifModifiedSince: lastModified
                        )
                }

                if let data = result.data, let response = result.response {
                    var expires: Date? = nil
                    if let expiresHeader = response.headers["expires"] {
                        expires = DataRequester.headerDateFormatter.date(from: expiresHeader)
                    }

                    if response.statusCode == 200,
                        let newImage = ImageCache.shared.addImage(
                            rawBytes: data,
                            name: imageName,
                            expires: expires
                        )
                    {
                        continuation.yield(newImage)
                    }
                }

                if let error = result.error { print(error) }
            }
        }
    }
}
