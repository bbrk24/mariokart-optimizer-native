import Foundation
import SwiftCrossUI

struct UnknownError: Error {
    var details: String
}

final class GameDataManager: SwiftCrossUI.ObservableObject {
    @SwiftCrossUI.Published var data: GameData?
    private let decoder = JSONDecoder()

    private init() {}
    static let shared = GameDataManager()

    private var dataPath: String {
        OptionsManager.shared.cacheDirUrl
            .appending(component: "data.json", directoryHint: .notDirectory)
            .relativePath
    }

    func loadData() async throws {
        if self.data != nil {
            return
        }

        let attributes = try? FileManager.default.attributesOfItem(atPath: dataPath)
        let modificationDate = (attributes?[.modificationDate] as? NSDate) as Date?

        var savedError: Error?
        do {
            if let data = FileManager.default.contents(atPath: dataPath) {
                self.data = try decoder.decode(GameData.self, from: data)
            }
        } catch {
            savedError = error
        }

        let response = await DataRequester()
            .getData(
                url: "https://bbrk24.github.io/mariokart-optimizer/data/switch.json",
                accept: "application/json",
                ifModifiedSince: modificationDate
            )

        let data = try response.result.get()
        if let httpResponse = response.response {
            if httpResponse.statusCode == 200 {
                if OptionsManager.shared.getOptions().useDiskCache {
                    _ = FileManager.default.createFile(atPath: dataPath, contents: data)
                }

                self.data = try decoder.decode(GameData.self, from: data)
                return
            } else if httpResponse.statusCode != 304 {
                savedError = UnknownError(details: response.debugDescription)
            }
        } else {
            savedError =
                savedError
                ?? UnknownError(details: "AFDataResponse contains neither response nor error")
        }

        if let savedError {
            throw savedError
        }
    }
}
