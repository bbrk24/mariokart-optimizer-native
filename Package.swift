// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MariokartOptimizer",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    dependencies: [
        .package(url: "https://github.com/stackotter/swift-cross-ui", revision: "b8496c0a4c960667eefb6969fe95afa280e9ce46"),
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.10.2")),
        .package(url: "https://github.com/stackotter/swift-image-formats", .upToNextMinor(from: "0.3.2")),
    ],
    targets: [
        .executableTarget(
            name: "MariokartOptimizer",
            dependencies: [
                .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
                .product(name: "DefaultBackend", package: "swift-cross-ui"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "ImageFormats", package: "swift-image-formats"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
