// swift-tools-version: 5.10

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Swuild",
    platforms: [
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "SwuildUtils", targets: ["SwuildUtils"]),
        .library(name: "BuildsDefinitions", targets: ["BuildsDefinitions"]),
        .library(name: "SwuildCore", targets: ["SwuildCore"]),
        .library(
            name: "SwuildPack",
            type: .dynamic,
            targets: ["SwuildPack"]
        ),
        .library(
            name: "iSwuild",
            targets: ["iSwuild"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: Version(1, 5, 0)),
        .package(url: "https://github.com/apple/swift-syntax.git", from: Version(600, 0, 0))
    ],
    targets: [
        .target(
            name: "BuildsDefinitions",
            path: "Sources/BuildsDefinitions"
        ),
        .target(
            name: "SwuildUtils",
            path: "Sources/SwuildUtils"
        ),
        .target(
            name: "SwuildCore",
            dependencies: [
                .byName(name: "BuildsDefinitions"),
                .byName(name: "SwuildUtils"),
            ],
            path: "Sources/SwuildCore"
        ),
        .target(
            name: "SwuildBuild",
            dependencies: [
                .byName(name: "BuildsDefinitions"),
                .byName(name: "SwuildUtils"),
            ],
            path: "Sources/SwuildBuild"
        ),
        .target(
            name: "SwuildPack",
            dependencies: [
                .byName(name: "BuildsDefinitions"),
                .byName(name: "SwuildCore"),
            ],
            path: "Sources/SwuildPack"
        ),
        .executableTarget(
            name: "Swuild",
            dependencies: [
                .byName(name: "BuildsDefinitions"),
                .byName(name: "SwuildUtils"),
                .byName(name: "SwuildCore"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/Swuild"
        ),
        .target(
            name: "iSwuild",
            dependencies: [
                .byName(name: "BuildsDefinitions"),
                .byName(name: "SwuildUtils"),
            ],
            path: "Sources/iSwuild"
        ),
    ]
)
