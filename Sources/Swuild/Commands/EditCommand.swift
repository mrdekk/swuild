//  Created by Denis Malykh on 19.11.2024.

import ArgumentParser
import BuildsDefinitions
import Foundation
import SwuildCore
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
        let flow = EditFlow(inputFolder: inputFolder)
        _ = try await flow.execute(context: makeContext())
    }
}

private let kContentsDeveloperSuffix = "/Contents/Developer"
private let kXcodePathKey = "xcode_path"

private struct EditFlow: Flow {
    public let name = "example_flow"

    public let platforms: [Platform] = [
        .iOS(version: .any),
        .macOS(version: .any),
    ]

    public let description = "Just an example flow"

    public func actions(for context: Context, and platform: Platform) -> [any Action] {
        return [
            ShellAction(
                hint: "Get Xcode path using xcode-select",
                command: "xcode-select",
                arguments: [
                    .raw(arg: "-p")
                ],
                captureOutputToKey: kXcodePathKey
            ),
            AdHocAction(hint: "Validate and process Xcode path") { context, _ in
                guard
                    let path: String = context.get(for: kXcodePathKey),
                    path.hasSuffix(kContentsDeveloperSuffix)
                else {
                    throw EditErrors.invalidXcodePath(message: "not valid path")
                }
                context.put(
                    for: kXcodePathKey,
                    option: StringOption(defaultValue: String(path.dropLast(kContentsDeveloperSuffix.count)))
                )
            },
            ShellAction(
                hint: "Open project in Xcode",
                command: "open",
                arguments: [
                    .raw(arg: "-a"),
                    .key(key: kXcodePathKey),
                    .raw(arg: inputFolder)
                ]
            )
        ]
    }

    private let inputFolder: String

    init(inputFolder: String) {
        self.inputFolder = inputFolder
    }
}
