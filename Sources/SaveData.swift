import Foundation

public struct Directions: Codable, Equatable {
    public var landSpeedDirection: OptimizeDirection
    public var waterSpeedDirection: OptimizeDirection
    public var airSpeedDirection: OptimizeDirection
    public var antigravSpeedDirection: OptimizeDirection
    public var accelDirection: OptimizeDirection
    public var weightDirection: OptimizeDirection
    public var landHandlingDirection: OptimizeDirection
    public var waterHandlingDirection: OptimizeDirection
    public var airHandlingDirection: OptimizeDirection
    public var antigravHandlingDirection: OptimizeDirection
    public var tractionDirection: OptimizeDirection
    public var miniTurboDirection: OptimizeDirection
    public var invulnDirection: OptimizeDirection
}

public struct SaveData: Codable, Equatable {
    public var minStats: BaseStatBlock
    public var maxStats: BaseStatBlock
    public var directions: Directions
    public var disallowedKartPieces: Set<String>
}

struct SaveDataInfo {
    var name: String
    var lastModified: Date?
    var isWritable: Bool
}

struct SaveDataManager {
    let encoder: PropertyListEncoder = {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        return encoder
    }()
    let decoder = PropertyListDecoder()

    func loadFileList() throws -> [SaveDataInfo] {
        let urls = try FileManager.default.contentsOfDirectory(
            at: OptionsManager.shared.dataDirUrl,
            includingPropertiesForKeys: [
                .addedToDirectoryDateKey, .contentModificationDateKey, .creationDateKey,
                .isReadableKey, .isWritableKey,
            ]
        )

        return try urls.compactMap { url -> SaveDataInfo? in
            guard !url.pathComponents.isEmpty, url.pathComponents.last!.hasSuffix(".plist") else {
                return nil
            }

            let resources = try url.resourceValues(forKeys: [
                .addedToDirectoryDateKey, .contentModificationDateKey, .creationDateKey,
                .isReadableKey, .isWritableKey,
            ])

            if resources.isReadable != true {
                return nil
            }

            let modifiedDate = [
                resources.addedToDirectoryDate, resources.contentModificationDate,
                resources.creationDate,
            ]
            .compacted().max()

            return SaveDataInfo(
                name: url.pathComponents.last!
                    .components(separatedBy: ".")
                    .dropLast()
                    .joined(separator: "."),
                lastModified: modifiedDate,
                isWritable: resources.isWritable!
            )
        }
    }

    func readSaveData(from fileName: String) -> Data? {
        let path = OptionsManager.shared.dataDirUrl
            .appending(component: "\(fileName).plist", directoryHint: .notDirectory)
            .relativePath

        let data = FileManager.default.contents(atPath: path)

        if data == nil {
            ErrorManager.addError(
                String(
                    format: localizations[OptionsManager.shared.locale]!.uiElements.openFailedError,
                    path
                )
            )
        }

        return data
    }

    func writeSaveData(_ data: Data, to fileName: String) {
        #if os(Windows)
            let attributes: [FileAttributeKey: Any] = [:]
        #else
            let attributes: [FileAttributeKey: Any] = [
                .posixPermissions: NSNumber(value: 0o600 as Int16)
            ]
        #endif

        let path = OptionsManager.shared.dataDirUrl
            .appending(component: "\(fileName).plist", directoryHint: .notDirectory)
            .relativePath

        if !FileManager.default.createFile(
            atPath: path,
            contents: data,
            attributes: attributes
        ) {
            ErrorManager.addError(
                String(
                    format: localizations[OptionsManager.shared.locale]!.uiElements.saveFailedError,
                    path
                )
            )
        }
    }
}
