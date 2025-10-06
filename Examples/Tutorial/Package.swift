// swift-tools-version: 5.10

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Tutorial",
    platforms: [
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "Tutorial",
            type: .dynamic,
            targets: ["Tutorial"]
        ),
    ],
    dependencies: [
        .package(path: "../.."), // Swuild package
    ],
    targets: [
        .target(
            name: "Tutorial",
            dependencies: [
                .product(name: "BuildsDefinitions", package: "Swuild"),
                .product(name: "SwuildCore", package: "Swuild"),
                .product(name: "FlowBuildableSwiftMacro", package: "Swuild"),
            ],
            path: ".",
            exclude: ["README.md"]
        ),
    ]
)