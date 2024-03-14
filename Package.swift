// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrivacyManifestJoin",
    platforms: [.macOS(.v14)],
    products: [
        .executable(
            name: "privacy-manifest-join",
            targets: [
                "PrivacyManifestJoinCLI",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
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
    ]
)
