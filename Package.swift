// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "MariokartOptimizer",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    dependencies: [
        .package(
            url: "https://github.com/stackotter/swift-cross-ui",
            revision: "d9af7bd0ee56e2c6baf0283bdd525822f7f38e66"
        ),
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.10.2")),
        .package(
            url: "https://github.com/stackotter/swift-image-formats",
            .upToNextMinor(from: "0.3.3")
        ),
        .package(url: "https://github.com/apple/swift-algorithms", .upToNextMajor(from: "1.2.1")),
        .package(url: "https://github.com/groue/Semaphore", .upToNextMinor(from: "0.1.0")),
    ],
    targets: [
        .executableTarget(
            name: "MariokartOptimizer",
            dependencies: [
                .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
                .product(name: "DefaultBackend", package: "swift-cross-ui"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "ImageFormats", package: "swift-image-formats"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Semaphore", package: "Semaphore"),
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
