import Foundation

final class OptionsManager {
#if os(iOS)
    // https://stackoverflow.com/a/69395400/6253337
    private let optionsDirUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let cacheDirUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
#else
#if os(Windows)
    private let optionsDirUrl = URL(
        filePath: ProcessInfo.processInfo.environment["APPDATA"]!,
        directoryHint: .isDirectory
    ).appending(component: "MariokartOptimizer", directoryHint: .isDirectory)
#else
    private let optionsDirUrl = URL.homeDirectory
        .appending(component: ".mkopt", directoryHint: .isDirectory)
#endif

    var cacheDirUrl: URL {
        optionsDirUrl.appending(component: "cache", directoryHint: .isDirectory)
    }
#endif

    private var options: Options?
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private var optionsFilePath: String {
        optionsDirUrl
            .appending(component: "options.json", directoryHint: .notDirectory)
            .relativePath
    }

    private init() {
#if !os(iOS)
        if !FileManager.default.fileExists(atPath: cacheDirUrl.relativePath) {
            try! FileManager.default.createDirectory(at: cacheDirUrl, withIntermediateDirectories: true)
        }
#endif
    }

    static let shared = OptionsManager()

    func getOptions() -> Options {
        if let options { return options }

        if !FileManager.default.fileExists(atPath: optionsFilePath) {
            options = .default
            return .default
        }

        guard let data = FileManager.default.contents(atPath: optionsFilePath) else {
            print("Error reading file \(optionsFilePath)")
            options = .default
            return .default
        }

        do {
            let decoded = try decoder.decode(Options.self, from: data)
            options = decoded
            return decoded
        } catch {
            print("Error decoding options: \(error)")
            options = .default
            return .default
        }
    }

    @discardableResult
    func setOptions(_ options: Options) -> Bool {
        if options == self.options { return true }

        self.options = options
        defer { ImageCache.shared.shrinkToFit() }

        do {
            let data = try encoder.encode(options)

            let success = FileManager.default.createFile(atPath: optionsFilePath, contents: data)
            return success
        } catch {
            print("Error encoding options: \(error)")
            return false
        }
    }
}

public enum Options: Codable, Equatable {
    case v1(
        memoryImageCacheSize: UInt,
        useDiskCache: Bool
    )

    var memoryImageCacheSize: UInt {
        switch self {
        case .v1(let memoryImageCacheSize, useDiskCache: _):
            return memoryImageCacheSize
        }
    }

    var useDiskCache: Bool {
        switch self {
        case .v1(memoryImageCacheSize: _, let useDiskCache):
            return useDiskCache
        }
    }

    static let `default` = Options.v1(memoryImageCacheSize: 4_200_000, useDiskCache: true)
}
