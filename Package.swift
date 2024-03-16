// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrivacyManifestJoin",
    platforms: [.macOS(.v14)],
    products: [
        .executable(
            name: "privacy-manifest-util",
            targets: [
                "PrivacyManifestJoinCLI",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "PrivacyManifestJoinCLI",
            dependencies: [
                "PrivacyManifestJoinCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(name: "PrivacyManifestJoinCore"),
        .testTarget(
            name: "CoreTests",
            dependencies: [
                "PrivacyManifestJoinCore",
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ]
        ),
    ]
)
