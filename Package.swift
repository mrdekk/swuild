// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Swuild",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "BuildsDefinitions", targets: ["BuildsDefinitions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: Version(1, 5, 0)),
    ],
    targets: [
        .target(
            name: "BuildsDefinitions",
            path: "Sources/BuildsDefinitions"
        ),
        .executableTarget(
            name: "Swuild",
            dependencies: [
                .byName(name: "BuildsDefinitions"),
            ],
            path: "Sources/Swuild"
        ),
    ]
)
