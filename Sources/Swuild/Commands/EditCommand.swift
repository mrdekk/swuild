//  Created by Denis Malykh on 19.11.2024.

import ArgumentParser
import Foundation
import SwuildUtils

enum EditErrors: Error {
    case invalidXcodePath(message: String)
}

struct Edit: AsyncParsableCommand {
    
    @ArgumentParser.Option(
        name: .shortAndLong,
        help: "Directory where Package.swift of Flow definition is located"
    )
    var inputFolder = FileManager.default.currentDirectoryPath

    mutating func run() async throws {
        let xcode = try findXcodePath()
        try sh(
            command: "open", "-a", xcode, inputFolder
        )
    }

    private func findXcodePath() throws -> String {
        let xcode = try sh(
            command: "xcode-select", "-p",
            captureOutput: true
        ).standardOutput
        guard xcode.hasSuffix(kContentsDeveloperSuffix) else {
            throw EditErrors.invalidXcodePath(message: "no contents/developer dir")
        }
        return String(xcode.dropLast(kContentsDeveloperSuffix.count))
    }
}

private let kContentsDeveloperSuffix = "/Contents/Developer"
