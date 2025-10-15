//  Created by Denis Malykh on 22.11.2024.

import Foundation
import BuildsDefinitions
import SwuildUtils

public enum ShellActionErrors: Error {
    case internalShellError(cause: Error)
}

public struct ShellAction: Action {

    public static let name = "sh"
    public static let description = "Action to execute shell commands"
    public static let authors = Author.defaultAuthors

    public static func isSupported(for platform: Platform) -> Bool {
        true
    }

    public let hint: String

    private let command: String
    private let arguments: [Argument<String>]
    private let captureOutputToKey: String?
    private let outputToConsole: Bool
    private let passEnvironment: ShellExecutor.Environment
    private let workingDirectory: String

    public init(
        hint: String = "-",
        command: String,
        arguments: [Argument<String>] = [],
        captureOutputToKey: String? = nil,
        outputToConsole: Bool = false,
        passEnvironment: ShellExecutor.Environment = .no,
        workingDirectory: String = FileManager.default.currentDirectoryPath
    ) {
        self.hint = hint
        self.command = command
        self.arguments = arguments
        self.captureOutputToKey = captureOutputToKey
        self.outputToConsole = outputToConsole
        self.passEnvironment = passEnvironment
        self.workingDirectory = workingDirectory
    }

    public func execute(context: Context, platform: Platform) async throws {
        do {
            let result = try sh(
                command: [command] + arguments.compactMap { try context.arg($0) },
                captureOutput: captureOutputToKey != nil,
                outputToConsole: outputToConsole,
                passEnvironment: passEnvironment,
                currentDirectoryPath: workingDirectory
            )
            if let key = captureOutputToKey {
                context.put(for: key, option: StringOption(defaultValue: result.standardOutput))
            }
        } catch {
            throw ShellActionErrors.internalShellError(cause: error)
        }
    }
}
