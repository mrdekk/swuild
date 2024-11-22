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
            name: "Tutorial",
            type: .dynamic,
            targets: ["Tutorial"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: Version(1, 5, 0)),
        .package(url: "https://github.com/apple/swift-syntax.git", from: Version(600, 0, 0))
    ],
    targets: [
        .macro(
            name: "FlowBuildableMacro",
            dependencies: [
                .byName(name: "BuildsDefinitions"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            path: "Sources/Macros/FlowBuildableMacro"
        ),
        .target(
            name: "FlowBuildableSwiftMacro",
            dependencies: [
                .byName(name: "FlowBuildableMacro"),
            ],
            path: "Sources/Macros/FlowBuildableSwiftMacro"
        ),
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
            name: "Tutorial",
            dependencies: [
                .byName(name: "BuildsDefinitions"),
                .byName(name: "SwuildCore"),
                .byName(name: "FlowBuildableMacro"),
                .byName(name: "FlowBuildableSwiftMacro"),
            ],
            path: "Sources/Tutorial",
            plugins: [
                .plugin(name: "FlowBuildableMacro"),
            ]
        ),
        .executableTarget(
            name: "Swuild",
            dependencies: [
                .byName(name: "BuildsDefinitions"),
                .byName(name: "SwuildUtils"),
                .byName(name: "SwuildCore"),
                .byName(name: "Tutorial"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/Swuild"
        ),
    ]
)
