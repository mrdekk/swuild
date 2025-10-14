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
    public let outputToConsole: Bool
    public let passEnvironment: Bool
    public let currentDirectoryPath: String?

    public init(
        command: String,
        arguments: [String],
        captureOutput: Bool,
        outputToConsole: Bool = false,
        passEnvironment: Bool = false,
        currentDirectoryPath: String? = nil
    ) {
        self.command = command
        self.arguments = arguments
        self.captureOutput = captureOutput
        self.outputToConsole = outputToConsole
        self.passEnvironment = passEnvironment
        self.currentDirectoryPath = currentDirectoryPath
    }

    public func run() throws -> Result {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments

        if passEnvironment {
            process.environment = ProcessInfo.processInfo.environment
        }

        if let path = currentDirectoryPath {
            process.currentDirectoryURL = URL(fileURLWithPath: path)
        }

        var stdoutFileURL: URL?
        var stderrFileURL: URL?
        var stdoutFileHandle: FileHandle?
        var stderrFileHandle: FileHandle?

        let stdoutPipe = outputToConsole ? Pipe() : nil
        let stderrPipe = outputToConsole ? Pipe() : nil

        if captureOutput || outputToConsole {
            if captureOutput {
                let stdoutFile = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                stdoutFileURL = stdoutFile
                FileManager.default.createFile(atPath: stdoutFile.path, contents: nil, attributes: nil)
                stdoutFileHandle = try? FileHandle(forWritingTo: stdoutFile)

                let stderrFile = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                stderrFileURL = stderrFile
                FileManager.default.createFile(atPath: stderrFile.path, contents: nil, attributes: nil)
                stderrFileHandle = try? FileHandle(forWritingTo: stderrFile)
            }

            if outputToConsole {
                if captureOutput {
                    if let stdoutPipe = stdoutPipe, let stdoutFileHandle = stdoutFileHandle {
                        stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
                            let data = handle.availableData
                            if !data.isEmpty {
                                // Write to file
                                if #available(macOS 10.15.4, *) {
                                    try? stdoutFileHandle.write(contentsOf: data)
                                } else {
                                    stdoutFileHandle.write(data)
                                }

                                if let output = String(data: data, encoding: .utf8) {
                                    print(output, terminator: "")
                                }
                            }
                        }
                        process.standardOutput = stdoutPipe
                    }

                    if let stderrPipe = stderrPipe, let stderrFileHandle = stderrFileHandle {
                        stderrPipe.fileHandleForReading.readabilityHandler = { handle in
                            let data = handle.availableData
                            if !data.isEmpty {
                                // Write to file
                                if #available(macOS 10.15.4, *) {
                                    try? stderrFileHandle.write(contentsOf: data)
                                } else {
                                    stderrFileHandle.write(data)
                                }

                                if let output = String(data: data, encoding: .utf8) {
                                    print(output, terminator: "")
                                }
                            }
                        }
                        process.standardError = stderrPipe
                    }
                } else {
                    if let stdoutPipe = stdoutPipe {
                        stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
                            let data = handle.availableData
                            if !data.isEmpty {
                                if let output = String(data: data, encoding: .utf8) {
                                    print(output, terminator: "")
                                }
                            }
                        }
                        process.standardOutput = stdoutPipe
                    }

                    if let stderrPipe = stderrPipe {
                        stderrPipe.fileHandleForReading.readabilityHandler = { handle in
                            let data = handle.availableData
                            if !data.isEmpty {
                                if let output = String(data: data, encoding: .utf8) {
                                    print(output, terminator: "")
                                }
                            }
                        }
                        process.standardError = stderrPipe
                    }
                }
            } else {
                process.standardOutput = stdoutFileHandle
                process.standardError = stderrFileHandle
            }
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
    outputToConsole: Bool = false,
    passEnvironment: Bool = false,
    currentDirectoryPath: String? = nil
) throws -> ShellExecutor.Result {
    let executablePath = try which(program: command)
    return try ShellExecutor(
        command: executablePath,
        arguments: parameters,
        captureOutput: captureOutput,
        outputToConsole: outputToConsole,
        passEnvironment: passEnvironment,
        currentDirectoryPath: currentDirectoryPath
    ).run()
}

@discardableResult
public func sh(
    command: [String],
    captureOutput: Bool = false,
    outputToConsole: Bool = false,
    passEnvironment: Bool = false,
    currentDirectoryPath: String? = nil
) throws -> ShellExecutor.Result {
    guard let executable = command.first else {
        throw ShellExecutor.Errors.missingCommand
    }
    return try sh(
        command: executable,
        parameters: Array(command[1...]),
        captureOutput: captureOutput,
        outputToConsole: outputToConsole,
        passEnvironment: passEnvironment,
        currentDirectoryPath: currentDirectoryPath
    )
}

@discardableResult
public func sh(
    command: String,
    captureOutput: Bool = false,
    outputToConsole: Bool = false,
    passEnvironment: Bool = false,
    currentDirectoryPath: String? = nil
) throws -> ShellExecutor.Result {
    return try sh(
        command: command.split(separator: " ").map(String.init),
        captureOutput: captureOutput,
        outputToConsole: outputToConsole,
        passEnvironment: passEnvironment,
        currentDirectoryPath: currentDirectoryPath
    )
}

@discardableResult
public func sh(
    command: String...,
    captureOutput: Bool = false,
    outputToConsole: Bool = false,
    passEnvironment: Bool = false,
    currentDirectoryPath: String? = nil
) throws -> ShellExecutor.Result {
    return try sh(
        command: command,
        captureOutput: captureOutput,
        outputToConsole: outputToConsole,
        passEnvironment: passEnvironment,
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
        captureOutput: true,
        outputToConsole: false
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
