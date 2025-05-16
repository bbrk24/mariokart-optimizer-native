import Foundation
import SwiftCrossUI

struct UnknownError: Error {
}

final class GameDataManager: ObservableObject {
    @Published var data: GameData?
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

        var decodingError: Error?
        do {
            if let data = FileManager.default.contents(atPath: dataPath) {
                self.data = try decoder.decode(GameData.self, from: data)
                return
            }
        } catch {
            decodingError = error
        }

        let response = await DataRequester().getData(
            url: "https://bbrk24.github.io/mariokart-optimizer/data/switch.json",
            accept: "application/json",
            ifModifiedSince: nil
        )

        let data = try response.result.get()
        if response.response?.statusCode == 200 {
            if OptionsManager.shared.getOptions().useDiskCache {
                _ = FileManager.default.createFile(atPath: dataPath, contents: data)
            }

            self.data = try decoder.decode(GameData.self, from: data)
            return
        }

        if let decodingError {
            throw decodingError
        }

        throw UnknownError()
    }
}