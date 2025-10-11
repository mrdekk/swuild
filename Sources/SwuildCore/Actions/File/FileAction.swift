//  Created by Denis Malykh on 04.04.2025.

import Foundation
import BuildsDefinitions
import SwuildUtils

public struct FileAction: Action {

    public enum Job {
        case makeDirectory(path: Argument<String>, ensureCreated: Bool)
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

    private let job: Job
    private let workingDirectory: String

    public init(
        job: Job,
        workingDirectory: String = FileManager.default.currentDirectoryPath
    ) {
        self.job = job
        self.workingDirectory = workingDirectory
    }

    public func execute(context: Context) async throws -> Result<Void, Error> {
        do {
            switch job {
            case let .makeDirectory(path, ensureCreated):
                guard let resolvedPath = try context.arg(path) else {
                    throw Errors.pathIsNotFound
                }
                try await makeDirectory(path: resolvedPath, ensureCreated: ensureCreated)

            case let .copy(from, to):
                guard let fromResolved = try context.arg(from),
                      let toResolved = try context.arg(to)
                else {
                    throw Errors.pathIsNotFound
                }
                try await copy(from: fromResolved, to: toResolved)
            }
            return .success(())
        } catch {
            throw error
        }
    }

    private func makeDirectory(path: String, ensureCreated: Bool) async throws {
        var arguments = ["mkdir"]
        if ensureCreated {
            arguments += ["-p"]
        }
        arguments += [path]
        try sh(
            command: arguments,
            currentDirectoryPath: workingDirectory
        )
    }

    private func copy(from: String, to: String) async throws {
        try sh(
            command: "cp", "-R", from, to,
            currentDirectoryPath: workingDirectory
        )
    }
}
