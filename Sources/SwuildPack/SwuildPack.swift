//  Created by Denis Malykh on 04.04.2025.

import BuildsDefinitions
import Foundation
import FlowBuildableSwiftMacro
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

    public let actions: [any Action] = [
        EchoAction { .raw(arg: "Packing Swuild to release binary") },
        SPMAction(
            job: .build(
                product: kSwuildProduct,
                configuration: kReleaseConfiguration
            )
        ),
        SPMAction(
            job: .gatherBinPath(
                product: kSwuildProduct,
                configuration: kReleaseConfiguration,
                toKey: kBinPathKey
            )
        ),
        FileAction(
            job: .makeDirectory(path: .raw(arg: kOutDirectory), ensureCreated: true)
        ),
        AdHocAction { context in
            guard
                let binPath: String = context.get(for: kBinPathKey)
            else {
                return .failure(Errors.binPathIsNotRetrieved)
            }
            let swuildBinaryPath = binPath + "/Swuild"
            context.put(for: kSwuildBinaryPathKey, option: .init(defaultValue: swuildBinaryPath))
            return .success(())
        },
        FileAction(
            job: .copy(from: .key(key: kSwuildBinaryPathKey), to: .raw(arg: kOutDirectory))
        ),
        TarAction(
            path: .raw(arg: kOutDirectory),
            tarPath: .raw(arg: kOutTarPath)
        )
    ]
}

#flowBuildable(SwuildPackFlow.self)

private let kSwuildProduct = "Swuild"
private let kReleaseConfiguration = "release"
private let kBinPathKey = "binPath"
private let kSwuildBinaryPathKey = "swuildBinaryPath"

private let kOutDirectory = ".build/releasePack"
private let kOutTarPath = ".build/swuild.tar.gz"
