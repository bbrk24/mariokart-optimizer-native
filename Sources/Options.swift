import Foundation
import SwiftCrossUI

final class OptionsManager: ObservableObject {
    private static let identifier = MKOApp.metadata?.identifier ?? "MariokartOptimizer"

    #if os(iOS)
        // https://stackoverflow.com/a/69395400/6253337
        private let optionsDirUrl =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let cacheDirUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]

        private init() {}
    #elseif os(macOS)
        private let optionsDirUrl =
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appending(component: OptionsManager.identifier, directoryHint: .isDirectory)

        let cacheDirUrl =
            FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask)[0]
            .appending(component: OptionsManager.identifier, directoryHint: .isDirectory)

        private init() {
            if !FileManager.default.fileExists(atPath: optionsDirUrl.relativePath) {
                try! FileManager.default.createDirectory(
                    at: optionsDirUrl,
                    withIntermediateDirectories: false
                )
            }
            if !FileManager.default.fileExists(atPath: cacheDirUrl.relativePath) {
                try! FileManager.default.createDirectory(
                    at: cacheDirUrl,
                    withIntermediateDirectories: false,
                    attributes: [.posixPermissions: NSNumber(value: 0o777 as Int16)]
                )
            }
        }
    #elseif os(Windows)
        private let optionsDirUrl = URL(
            filePath: ProcessInfo.processInfo.environment["APPDATA"]!,
            directoryHint: .isDirectory
        )
        .appending(component: OptionsManager.identifier, directoryHint: .isDirectory)

        var cacheDirUrl: URL {
            optionsDirUrl.appending(component: "Cache", directoryHint: .isDirectory)
        }

        private init() {
            if !FileManager.default.fileExists(atPath: cacheDirUrl.relativePath) {
                try! FileManager.default.createDirectory(
                    at: cacheDirUrl,
                    withIntermediateDirectories: true
                )
            }
        }
    #else  // os(Linux)
        private let optionsDirUrl =
            (ProcessInfo.processInfo.environment["XDG_CONFIG_HOME"]
            .flatMap {
                $0.hasPrefix("/") ? URL(filePath: $0) : nil
            } ?? URL.homeDirectory.appending(component: ".config", directoryHint: .isDirectory))
            .appending(component: OptionsManager.identifier, directoryHint: .isDirectory)

        let cacheDirUrl =
            (ProcessInfo.processInfo.environment["XDG_CACHE_HOME"]
            .flatMap {
                $0.hasPrefix("/") ? URL(filePath: $0) : nil
            } ?? URL.homeDirectory.appending(component: ".cache", directoryHint: .isDirectory))
            .appending(component: OptionsManager.identifier, directoryHint: .isDirectory)

        private init() {
            if !FileManager.default.fileExists(atPath: optionsDirUrl.relativePath) {
                try! FileManager.default.createDirectory(
                    at: optionsDirUrl,
                    withIntermediateDirectories: true,
                    attributes: [.posixPermissions: NSNumber(value: 0o700 as Int16)]
                )
            }
            if !FileManager.default.fileExists(atPath: cacheDirUrl.relativePath) {
                try! FileManager.default.createDirectory(
                    at: cacheDirUrl,
                    withIntermediateDirectories: true
                )
            }
        }
    #endif

    @Published private var options: Options?
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private var optionsFilePath: String {
        optionsDirUrl.appending(component: "options.json", directoryHint: .notDirectory)
            .relativePath
    }

    var locale: Locale { getOptions().locale }

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
        useDiskCache: Bool,
        locale: Locale
    )

    var memoryImageCacheSize: UInt {
        switch self {
        case .v1(let memoryImageCacheSize, useDiskCache: _, locale: _):
            return memoryImageCacheSize
        }
    }

    var useDiskCache: Bool {
        switch self {
        case .v1(memoryImageCacheSize: _, let useDiskCache, locale: _):
            return useDiskCache
        }
    }

    var locale: Locale {
        switch self {
        case .v1(memoryImageCacheSize: _, useDiskCache: _, let locale):
            return locale
        }
    }

    static let `default` = Options.v1(
        memoryImageCacheSize: 4_200_000,
        useDiskCache: true,
        locale: Locale(identifier: "en_US")
    )
}
