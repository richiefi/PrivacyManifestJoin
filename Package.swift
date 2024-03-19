// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrivacyManifestUtil",
    platforms: [.macOS(.v14)],
    products: [
        .executable(
            name: "privacy-manifest-util",
            targets: [
                "PrivacyManifestUtilCLI",
            ]
        ),
        .library(
            name: "PrivacyManifestKit",
            targets: ["PrivacyManifestKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "PrivacyManifestUtilCLI",
            dependencies: [
                "PrivacyManifestKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(name: "PrivacyManifestKit"),
        .testTarget(
            name: "CoreTests",
            dependencies: [
                "PrivacyManifestKit",
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ]
        ),
    ]
)
