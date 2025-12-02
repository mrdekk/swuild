# iSwuild

iOS-specific build actions for Swuild.

## Overview

The iSwuild module provides iOS and macOS specific build actions that integrate with Xcode tools. These actions are designed to work with the Swuild build system to automate common iOS/macOS development tasks.

## Available Actions

### Xcodebuild

The `Xcodebuild` action provides a comprehensive interface for building iOS and macOS projects using the xcodebuild command-line tool. It supports various build configurations, code signing options, archive/export settings, and formatting options.

#### Usage

```swift
import iSwuild

let params = XcodebuildParams(
    project: XcodebuildParams.ProjectConfig(
        workspace: "MyApp.xcworkspace",
        scheme: "MyApp"
    ),
    build: XcodebuildParams.BuildConfig(
        clean: true
    ),
    archive: XcodebuildParams.ArchiveConfig(
        archivePath: "build/MyApp.xcarchive"
    ),
    codeSigning: XcodebuildParams.CodeSigningConfig(
        skipCodesigning: true
    ),
    export: XcodebuildParams.ExportConfig(),
    output: XcodebuildParams.OutputConfig(
        outputDirectory: "build"
    ),
    formatting: XcodebuildParams.FormattingConfig(),
    package: XcodebuildParams.PackageConfig()
)

let action = Xcodebuild(hint: "Build MyApp", params: params)
```

### CocoaPods

The `CocoaPods` action provides integration with CocoaPods dependency manager. It supports installing, updating, and managing CocoaPods dependencies.

#### Usage

```swift
import iSwuild

let params = CocoaPodsParams(
    command: .install,
    repoUpdate: true
)

let action = CocoaPods(hint: "Install CocoaPods dependencies", params: params)
```

### CreateXcframework

The `CreateXcframework` action provides functionality for packaging multiple build configurations of a given library or framework into a single xcframework using the xcodebuild tool.

#### Usage

```swift
import iSwuild

// Create xcframework from frameworks
let frameworks = [
    CreateXcframeworkParams.Framework(path: "FrameworkA.framework"),
    CreateXcframeworkParams.Framework(path: "FrameworkB.framework", dsym: "FrameworkB.framework.dSYM")
]

let params = CreateXcframeworkParams(
    binaries: .frameworks(frameworks),
    outputPath: "UniversalFramework.xcframework"
)

let action = CreateXcframework(hint: "Create xcframework from frameworks", params: params)

// Create xcframework from libraries
let libraries = [
    CreateXcframeworkParams.Library(path: "LibraryA.so", dsym: "libraryA.so.dSYM"),
    CreateXcframeworkParams.Library(path: "LibraryB.so", headers: "LibraryBHeaders")
]

let params2 = CreateXcframeworkParams(
    binaries: .libraries(libraries),
    outputPath: "UniversalLibrary.xcframework",
    allowInternalDistribution: true
)

let action2 = CreateXcframework(hint: "Create xcframework from libraries", params: params2)

// Create xcframework from simple framework paths
let params3 = CreateXcframeworkParams(
    frameworkPaths: ["FrameworkA.framework", "FrameworkB.framework"],
    outputPath: "SimpleFramework.xcframework"
)

let action3 = CreateXcframework(hint: "Create xcframework from simple framework paths", params: params3)

// Create xcframework from simple library paths
let params4 = CreateXcframeworkParams(
    libraryPaths: ["LibraryA.so", "LibraryB.so"],
    outputPath: "SimpleLibrary.xcframework"
)

let action4 = CreateXcframework(hint: "Create xcframework from simple library paths", params: params4)
```

## Parameters

Each action has a corresponding parameters struct that organizes configuration options into logical groups:

- `XcodebuildParams` - Configuration for xcodebuild action
- `CocoaPodsParams` - Configuration for CocoaPods action
- `CreateXcframeworkParams` - Configuration for create_xcframework action

These parameter structs provide type-safe configuration with sensible defaults and clear documentation for each option.