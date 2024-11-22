//  Created by Denis Malykh on 22.11.2024.

import Foundation

public class ShellExecutor {
    public struct Result {
        public let exitStatus: Int
        public let standardOutput: String
        public let standardError: String

        public var isSucceeded: Bool {
            return exitStatus == 0
        }
    }

    enum Errors: Error {
        case missingCommand
    }

    public let command: String
    public let arguments: [String]
    public let captureOutput: Bool
    public let currentDirectoryPath: String?

    public init(command: String, arguments: [String], captureOutput: Bool, currentDirectoryPath: String? = nil) {
        self.command = command
        self.arguments = arguments
        self.captureOutput = captureOutput
        self.currentDirectoryPath = currentDirectoryPath
    }

    public func run() throws -> Result {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments

        if let path = currentDirectoryPath {
            process.currentDirectoryURL = URL(fileURLWithPath: path)
        }

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        if captureOutput {
            process.standardOutput = outputPipe
            process.standardError = errorPipe
        }

        try process.run()
        process.waitUntilExit()

        let standardOutput = captureOutput ? outputPipe.string ?? "" : ""
        let standardError = captureOutput ? errorPipe.string ?? "" : ""
        return Result(
            exitStatus: Int(process.terminationStatus),
            standardOutput: standardOutput,
            standardError: standardError
        )
    }
}

@discardableResult
public func sh(
    command: String,
    parameters: [String],
    captureOutput: Bool = false,
    currentDirectoryPath: String? = nil
) throws -> ShellExecutor.Result {
    let executablePath = try which(program: command)
    return try ShellExecutor(
        command: executablePath,
        arguments: parameters,
        captureOutput: captureOutput,
        currentDirectoryPath: currentDirectoryPath
    ).run()
}

@discardableResult
public func sh(
    command: [String],
    captureOutput: Bool = false,
    currentDirectoryPath: String? = nil
) throws -> ShellExecutor.Result {
    guard let executable = command.first else {
        throw ShellExecutor.Errors.missingCommand
    }
    return try sh(
        command: executable,
        parameters: Array(command[1...]),
        captureOutput: captureOutput,
        currentDirectoryPath: currentDirectoryPath
    )
}

@discardableResult
public func sh(
    command: String,
    captureOutput: Bool = false,
    currentDirectoryPath: String? = nil
) throws -> ShellExecutor.Result {
    return try sh(
        command: command.split(separator: " ").map(String.init),
        captureOutput: captureOutput,
        currentDirectoryPath: currentDirectoryPath
    )
}

@discardableResult
public func sh(
    command: String...,
    captureOutput: Bool = false,
    currentDirectoryPath: String? = nil
) throws -> ShellExecutor.Result {
    return try sh(
        command: command,
        captureOutput: captureOutput,
        currentDirectoryPath: currentDirectoryPath
    )
}

public func which(program: String) throws -> String {
    let result = try ShellExecutor(
        command: "/usr/bin/env",
        arguments: [
            "which",
            program
        ],
        captureOutput: true
    ).run()
    return result.standardOutput
}

private extension Pipe {
    var string: String? {
        let data = fileHandleForReading.readDataToEndOfFile()
        let str = String(data: data, encoding: .utf8)
        return str?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
