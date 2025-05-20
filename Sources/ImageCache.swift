import ImageFormats
import Foundation

struct CacheEntry {
    var image: Image<RGBA>
    var lastUsed: Date
    var lastModified: Date
    var expires: Date?

    var estimatedSize: UInt {
        UInt(MemoryLayout<CacheEntry>.size) + UInt(image.bytes.count)
    }
}

final class ImageCache {
    private var cache = Dictionary<String, CacheEntry>()
    private var totalMemory: UInt = 0

    private init() {}
    static let shared = ImageCache()

    private nonisolated func addImage(
        rawBytes: Data,
        name: String,
        expires: Date?,
        saveToDiskIfAllowed: Bool,
        lastModified: Date
    ) -> Image<RGBA>? {
        var decodedImage: Image<RGBA>
        do {
            decodedImage = try Image<RGBA>.load(from: Array(rawBytes))
        } catch {
            print("Error decoding image: \(error)")
            return nil
        }

        let newEntry = CacheEntry(
            image: decodedImage,
            lastUsed: .now,
            lastModified: lastModified,
            expires: expires
        )

        Task { @MainActor in
            let oldMemoryUsed = cache[name]?.estimatedSize ?? 0
            let newMemoryUsed = newEntry.estimatedSize

            cache[name] = newEntry
            totalMemory = totalMemory + newMemoryUsed - oldMemoryUsed

            shrinkToFit()
        }

        let path = OptionsManager.shared.cacheDirUrl
            .appending(component: name, directoryHint: .notDirectory)
            .relativePath

        if OptionsManager.shared.getOptions().useDiskCache {
            if saveToDiskIfAllowed {
                _ = FileManager.default.createFile(atPath: path, contents: rawBytes)
            }
        } else if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }

        return decodedImage
    }

    @discardableResult
    nonisolated func addImage(
        rawBytes: Data,
        name: String,
        expires: Date?
    ) -> Image<RGBA>? {
        return addImage(
            rawBytes: rawBytes,
            name: name,
            expires: expires,
            saveToDiskIfAllowed: true,
            lastModified: .now
        )
    }

    func getImage(name: String) -> (image: Image<RGBA>, lastModified: Date, expires: Date?)? {
        if let entry = cache[name] {
            cache[name]!.lastUsed = .now
            if let expiration = entry.expires, expiration < .now {
                cache[name] = nil
                totalMemory -= entry.estimatedSize
            }

            return (entry.image, entry.lastModified, entry.expires)
        }

        let path = OptionsManager.shared.cacheDirUrl
            .appending(component: name, directoryHint: .notDirectory)
            .relativePath

        let attributes = try? FileManager.default.attributesOfItem(atPath: path)

        if let modificationDate = (attributes?[.modificationDate] as? NSDate) as Date?,
            let data = FileManager.default.contents(atPath: path),
            let image = addImage(
                rawBytes: data,
                name: name,
                expires: nil,
                saveToDiskIfAllowed: false,
                lastModified: modificationDate
            )
        {
            return (image, lastModified: modificationDate, expires: nil)
        }

        return nil
    }

    func shrinkToFit() {
        let expired =
            cache.filter {
                if let expiration = $1.expires {
                    expiration < .now
                } else {
                    false
                }
            }
            .map { ($0, $1.estimatedSize) }

        for (name, amount) in expired {
            cache[name] = nil
            totalMemory -= amount
        }

        let maxMemory = OptionsManager.shared.getOptions().memoryImageCacheSize
        if totalMemory <= maxMemory {
            return
        }

        let sortedNamesAndMemory =
            cache.sorted {
                if $0.value.lastUsed == $1.value.lastUsed {
                    $0.value.estimatedSize > $1.value.estimatedSize
                } else {
                    $0.value.lastUsed < $1.value.lastUsed
                }
            }
            .map { ($0, $1.estimatedSize) }

        for (name, amount) in sortedNamesAndMemory {
            cache[name] = nil
            totalMemory -= amount

            if totalMemory <= maxMemory {
                return
            }
        }
    }
}
