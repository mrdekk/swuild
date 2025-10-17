//  Created by Denis Malykh on 04.04.2025.

import BuildsDefinitions
import Foundation
import SwuildCore

public struct SwuildPackFlow: Flow {
    public enum Errors: Error {
        case binPathIsNotRetrieved
    }

    public let name = "swuild_pack_flow"

    public let platforms: [Platform] = [
        .iOS(version: .any),
        .macOS(version: .any),
    ]

    public let description = "Special flow to pack Swuild Binary"

    public func actions(for context: Context, and platform: Platform) -> [any Action] {
        return [
            EchoAction(hint: "Start Swuild packing process", contentProvider: { .raw(arg: "Packing Swuild to release binary") }),
            SPMAction(
                hint: "Build Swuild product in release configuration",
                job: .build(
                    product: kSwuildProduct,
                    configuration: kReleaseConfiguration
                )
            ),
            SPMAction(
                hint: "Gather binary path for Swuild product",
                job: .gatherBinPath(
                    product: kSwuildProduct,
                    configuration: kReleaseConfiguration,
                    toKey: kBinPathKey
                )
            ),
            FileAction(
                hint: "Create output directory for release pack",
                job: .makeDirectory(path: .raw(arg: kOutDirectory), ensureCreated: true)
            ),
            AdHocAction(hint: "Process binary path and set Swuild binary path") { context, platform in
                guard
                    let binPath: String = context.get(for: kBinPathKey)
                else {
                    throw Errors.binPathIsNotRetrieved
                }
                let swuildBinaryPath = binPath + "/Swuild"
                context.put(for: kSwuildBinaryPathKey, option: .init(defaultValue: swuildBinaryPath))
            },
            FileAction(
                hint: "Copy Swuild binary to output directory",
                job: .copy(from: .key(key: kSwuildBinaryPathKey), to: .raw(arg: kOutDirectory), wildcardMode: .first)
            ),
            TarAction(
                hint: "Create tar archive of release pack",
                path: .raw(arg: kOutDirectory),
                tarPath: .raw(arg: kOutTarPath)
            )
        ]
    }
}

@_cdecl("makeFlow")
public func makeFlow() -> UnsafeMutableRawPointer {
    flow { SwuildPackFlow() }
}

private let kSwuildProduct = "Swuild"
private let kReleaseConfiguration = "release"
private let kBinPathKey = "binPath"
private let kSwuildBinaryPathKey = "swuildBinaryPath"

private let kOutDirectory = ".build/releasePack"
private let kOutTarPath = ".build/swuild.tar.gz"
