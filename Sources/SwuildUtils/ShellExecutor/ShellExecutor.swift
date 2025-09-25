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

        var stdoutFileURL: URL?
        var stderrFileURL: URL?
        var stdoutFileHandle: FileHandle?
        var stderrFileHandle: FileHandle?

        if captureOutput {
            let stdoutFile = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            stdoutFileURL = stdoutFile
            FileManager.default.createFile(atPath: stdoutFile.path, contents: nil, attributes: nil)
            stdoutFileHandle = try? FileHandle(forWritingTo: stdoutFile)
            process.standardOutput = stdoutFileHandle

            let stderrFile = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            stderrFileURL = stderrFile
            FileManager.default.createFile(atPath: stderrFile.path, contents: nil, attributes: nil)
            stderrFileHandle = try? FileHandle(forWritingTo: stderrFile)
            process.standardError = stderrFileHandle
        } else {
            process.standardOutput = nil
            process.standardError = nil
        }

        try process.run()
        process.waitUntilExit()

        let standardOutput = {
            if captureOutput, let stdoutFileURL {
                do {
                    let stdoutData = try Data(contentsOf: stdoutFileURL)
                    try? FileManager.default.removeItem(at: stdoutFileURL)
                    return String(data: stdoutData, encoding: .utf8) ?? ""
                } catch {
                    return "error on getting stdout result \(error)"
                }
            }
            return ""
        }()

        let standardError = {
            if captureOutput, let stderrFileURL {
                do {
                    let stderrData = try Data(contentsOf: stderrFileURL)
                    try? FileManager.default.removeItem(at: stderrFileURL)
                    return String(data: stderrData, encoding: .utf8) ?? ""
                } catch {
                    return "error on getting stderr result \(error)"
                }
            }
            return ""
        }()

        return Result(
            exitStatus: Int(process.terminationStatus),
            standardOutput: standardOutput.trimmingCharacters(in: .whitespacesAndNewlines),
            standardError: standardError.trimmingCharacters(in: .whitespacesAndNewlines)
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
