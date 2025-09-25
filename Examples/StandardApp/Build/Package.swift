// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "StandardAppBuild",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "StandardAppBuild",
            type: .dynamic,
            targets: ["StandardAppBuild"]
        ),
    ],
    dependencies: [
        // Depending on iSwuild from the parent package
        .package(path: "../../../"),
    ],
    targets: [
        .target(
            name: "StandardAppBuild",
            dependencies: [
                .product(name: "iSwuild", package: "Swuild"),
                .product(name: "BuildsDefinitions", package: "Swuild"),
                .product(name: "SwuildCore", package: "Swuild"),
                .product(name: "FlowBuildableSwiftMacro", package: "Swuild"),
            ],
            path: "Sources"
        ),
    ]
)
