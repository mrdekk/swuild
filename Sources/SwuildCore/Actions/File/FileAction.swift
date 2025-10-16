//  Created by Denis Malykh on 04.04.2025.

import Foundation
import BuildsDefinitions
import SwuildUtils

public struct FileAction: Action {

    public enum Job {
        case removeDirectory(path: Argument<String>)
        case makeDirectory(path: Argument<String>, ensureCreated: Bool)
        case recreateDirectory(path: Argument<String>, ensureCreated: Bool)
        case copy(from: Argument<String>, to: Argument<String>)
    }

    public enum Errors: Error {
        case pathIsNotFound
    }

    public static let name = "file"
    public static let description = "Action to execute some predfined file operations"
    public static let authors = Author.defaultAuthors

    public static func isSupported(for platform: Platform) -> Bool {
        true
    }

    public let hint: String

    private let job: Job
    private let workingDirectory: String
    private let outputToConsole: Bool

    public init(
        hint: String = "-",
        job: Job,
        outputToConsole: Bool = false,
        workingDirectory: String = FileManager.default.currentDirectoryPath
    ) {
        self.hint = hint
        self.job = job
        self.outputToConsole = outputToConsole
        self.workingDirectory = workingDirectory
    }

    public func execute(context: Context, platform: Platform) async throws {
        do {
            switch job {
            case let .removeDirectory(path):
                guard let resolvedPath = try context.arg(path) else {
                    throw Errors.pathIsNotFound
                }

                try await removeDirectory(path: resolvedPath)

            case let .makeDirectory(path, ensureCreated):
                guard let resolvedPath = try context.arg(path) else {
                    throw Errors.pathIsNotFound
                }
                try await makeDirectory(path: resolvedPath, ensureCreated: ensureCreated)

            case let .recreateDirectory(path, ensureCreated):
                guard let resolvedPath = try context.arg(path) else {
                    throw Errors.pathIsNotFound
                }

                try await removeDirectory(path: resolvedPath)
                try await makeDirectory(path: resolvedPath, ensureCreated: ensureCreated)

            case let .copy(from, to):
                guard let fromResolved = try context.arg(from),
                      let toResolved = try context.arg(to)
                else {
                    throw Errors.pathIsNotFound
                }
                try await copy(from: fromResolved, to: toResolved)
            }
        } catch {
            throw error
        }
    }

    private func removeDirectory(path: String) async throws {
        let fileManager = FileManager.default

        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: path, isDirectory: &isDirectory)

        if exists, isDirectory.boolValue {
            try fileManager.removeItem(at: URL(fileURLWithPath: path))
        }
    }

    private func makeDirectory(path: String, ensureCreated: Bool) async throws {
        try FileManager.default.createDirectory(
            at: URL(fileURLWithPath: path),
            withIntermediateDirectories: ensureCreated
        )
    }

    private func copy(from: String, to: String) async throws {
        try FileUtils.recursiveCopy(
            from: from,
            to: URL(fileURLWithPath: to),
            outputToConsole: outputToConsole
        )
    }
}
