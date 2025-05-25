// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MariokartOptimizer",
    platforms: [
        .macOS(.v13),
        // .iOS(.v16),
    ],
    dependencies: [
        .package(url: "https://github.com/stackotter/swift-cross-ui", revision: "fba2e4575ee105a5a2844ec8e9f0c2412167846b"),
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.10.2")),
        .package(url: "https://github.com/stackotter/swift-image-formats", .upToNextMinor(from: "0.3.2")),
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
        ),
    ],
    swiftLanguageModes: [.v5]
)
