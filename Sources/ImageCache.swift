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

actor ImageCache {
    private var cache = Dictionary<String, CacheEntry>()
    private var totalMemory: UInt = 0

    private init() {}
    static let shared = ImageCache()

    private nonisolated func withIsolation<T>(
        _ callback: (isolated ImageCache) async -> sending T
    ) async -> sending T {
        return await callback(self)
    }

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

        Task {
            await withIsolation { this in
                let oldMemoryUsed = this.cache[name]?.estimatedSize ?? 0
                let newMemoryUsed = newEntry.estimatedSize

                this.cache[name] = newEntry
                this.totalMemory = this.totalMemory + newMemoryUsed - oldMemoryUsed

                this.shrinkToFit()
            }
        }

        let path = OptionsManager.shared.cacheDirUrl
            .appending(component: name, directoryHint: .notDirectory)
            .relativePath

        Task { @MainActor in
            if OptionsManager.shared.getOptions().useDiskCache {
                if saveToDiskIfAllowed {
                    _ = FileManager.default.createFile(atPath: path, contents: rawBytes)
                }
            } else if FileManager.default.fileExists(atPath: path) {
                try? FileManager.default.removeItem(atPath: path)
            }
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

    nonisolated func getImage(
        name: String
    ) async -> (image: Image<RGBA>, lastModified: Date, expires: Date?)? {
        if let result = await withIsolation({ this in
            if let entry = this.cache[name] {
                this.cache[name]!.lastUsed = .now
                if let expiration = entry.expires, expiration < .now {
                    this.cache[name] = nil
                    this.totalMemory -= entry.estimatedSize
                }

                return (entry.image, entry.lastModified, entry.expires)
            }
            return nil
        }) {
            return result
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
