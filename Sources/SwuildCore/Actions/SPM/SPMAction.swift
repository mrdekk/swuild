//  Created by Denis Malykh on 22.11.2024.

import Foundation
import BuildsDefinitions
import SwuildUtils

public struct SPMAction: Action {

    public enum Job {
        case build(product: String, configuration: String)
        case gatherBinPath(product: String, configuration: String, toKey: String)
        case gatherPackageDump(toKey: String)
    }

    public static let name = "spm"
    public static let description = "Action to build something with swift build"
    public static let authors = Author.defaultAuthors

    public static func isSupported(for platform: Platform) -> Bool {
        true
    }

    public let hint: String

    private let job: Job
    private let workingDirectory: String

    public init(
        hint: String = "-",
        job: Job,
        workingDirectory: String = FileManager.default.currentDirectoryPath
    ) {
        self.hint = hint
        self.job = job
        self.workingDirectory = workingDirectory
    }

    public func execute(context: Context, platform: Platform) async throws {
        do {
            switch job {
            case let .build(product, configuration):
                try await build(product: product, configuration: configuration)

            case let .gatherBinPath(product, configuration, toKey):
                let path = try await gatherBinPath(product: product, configuration: configuration)
                context.put(for: toKey, option: StringOption(defaultValue: path))

            case let .gatherPackageDump(toKey):
                let dump = try await gatherPackageDump()
                context.put(for: toKey, option: PackageDumpOption(defaultValue: dump))
            }
        } catch {
            throw error
        }
    }

    private func build(product: String, configuration: String) async throws {
        try sh(
            command: "swift", "build", "--product", product, "--configuration", configuration,
            currentDirectoryPath: workingDirectory
        )
    }

    private func gatherBinPath(product: String, configuration: String) async throws -> String {
        let result = try sh(
            command: "swift", "build", "--product", product, "--configuration", configuration, "--show-bin-path",
            captureOutput: true,
            currentDirectoryPath: workingDirectory
        )
        return result.standardOutput
    }

    private func gatherPackageDump() async throws -> PackageDump {
        let result = try sh(
            command: "swift", "package", "dump-package",
            captureOutput: true,
            currentDirectoryPath: workingDirectory
        )
        let data = Data(result.standardOutput.utf8)
        return try JSONDecoder().decode(PackageDump.self, from: data)
    }
}
