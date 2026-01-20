//  Created by Denis Malykh on 24.09.2025.

import BuildsDefinitions
import Foundation
import SwuildCore
import iSwuild

/// A build flow for the StandardApp example project
public struct StandardAppBuildFlow: Flow {
    public let name = "standard_app_build"
    
    public let platforms: [Platform] = [
        .iOS(version: .any),
    ]
    
    public let description = "Build flow for the StandardApp example project"
    
    public func actions(for context: Context, and platform: Platform) -> [any Action] {
        return [
            FileAction(
                hint: "Create logs directory",
                job: .makeDirectory(path: .raw(arg: "./logs"), ensureCreated: true)
            ),
            FileAction(
                hint: "Create output directory",
                job: .makeDirectory(path: .raw(arg: "./output"), ensureCreated: true)
            ),

            Xcodebuild(
                hint: "Build and archive StandardApp for iOS",
                params: .init(
                    project: .init(
                        project: "../StandardApp/StandardApp.xcodeproj",
                        scheme: "StandardApp",
                        configuration: "Release"
                    ),
                    build: .init(
                        clean: true,
                        sdk: "iphoneos"
                    ),
                    archive: .init(
                        archivePath: "/tmp/StandardApp.xcarchive",
                        skipArchive: false
                    ),
                    codeSigning: .init(
                        skipCodesigning: true  // Skip codesigning for example purposes
                    ),
                    export: .init(
                        skipPackageIpa: true // Skip packaging for example purposes
                    ),
                    output: .init(
                        outputDirectory: "./output",
                        buildlogPath: "./logs"
                    ),
                    formatting: .init(),
                    package: .init(),
                    useShellCommand: ["/bin/bash", "-l", "-c"]
                ),
                outputToConsole: true
            )
        ]
    }
}

@_cdecl("makeFlow")
public func makeFlow() -> UnsafeMutableRawPointer {
    flow { StandardAppBuildFlow() }
}