//  Created by Denis Malykh on 04.04.2025.

import Foundation
import BuildsDefinitions
import SwuildUtils

public struct TarAction: Action {
    public enum Errors: Error {
        case sourceFileNotExists
    }

    public static let name = "echo"
    public static let description = "Simple echo action for tests"
    public static let authors = Author.defaultAuthors

    public static func isSupported(for platform: Platform) -> Bool {
        true
    }

    private let path: Argument<String>
    private let tarPath: Argument<String>
    private let workingDirectory: String

    public init(
        path: Argument<String>,
        tarPath: Argument<String>,
        workingDirectory: String = FileManager.default.currentDirectoryPath
    ) {
        self.path = path
        self.tarPath = tarPath
        self.workingDirectory = workingDirectory
    }

    public func execute(context: Context) async throws -> Result<Void, Error> {
        guard let pathResolved = context.arg(path) else {
            throw ActionErrors.argumentNotResolved(name: "path")
        }
        guard let tarPathResolved = context.arg(tarPath) else {
            throw ActionErrors.argumentNotResolved(name: "tarPath")
        }

        let fileManager = FileManager.default

        let sourcePath = workingDirectory + "/" + pathResolved
        guard fileManager.fileExists(atPath: sourcePath) else {
            throw Errors.sourceFileNotExists
        }

        let destinationPath = workingDirectory + "/" + tarPathResolved
        if fileManager.fileExists(atPath: destinationPath) {
            try fileManager.removeItem(atPath: destinationPath)
        }

        try sh(
            command: "tar", "-cvf", tarPathResolved, "-C", "\(workingDirectory)/\(pathResolved)", ".",
            currentDirectoryPath: workingDirectory
        )

        return .success(())
    }
}
