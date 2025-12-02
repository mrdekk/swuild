//  Created by Denis Malykh on 02.12.2025.

import Foundation
import BuildsDefinitions
import SwuildUtils

/// This action provides functionality for packaging multiple build configurations
/// of a given library or framework into a single xcframework using the xcodebuild tool.
///
/// The action supports both frameworks and libraries with optional dSYM and header files.
public struct CreateXcframework: Action {
    public let hint: String
    
    public enum Errors: Swift.Error, LocalizedError {
        case missingRequiredParameter(String)
        case executionFailed(String)
        case validationFailed(String)
        
        public var errorDescription: String? {
            switch self {
            case .missingRequiredParameter(let parameter):
                return "Missing required parameter: \(parameter)"
            case .executionFailed(let message):
                return "Execution failed: \(message)"
            case .validationFailed(let message):
                return "Validation failed: \(message)"
            }
        }
    }
    
    // MARK: - Properties
    
    /// The parameters for configuring the create_xcframework action
    public let params: CreateXcframeworkParams

    // MARK: - Initialization
    
    /// Initialize a CreateXcframework action with the specified parameters
    /// - Parameter params: The parameters to configure the create_xcframework action
    public init(hint: String = "-", params: CreateXcframeworkParams) {
        self.hint = hint
        self.params = params
    }
    
    // MARK: - BuildsDefinitions.Action
    
    public static let name = "create_xcframework"
    public static let description = "Package multiple build configs of a library/framework into a single xcframework"
    public static let authors = Author.defaultAuthors
    
    public static func isSupported(for platform: Platform) -> Bool {
        switch platform {
        case .iOS, .macOS:
            return true
        }
    }
    
    public func execute(context: Context, platform: Platform) async throws {
        try validateArtifacts()
        
        let command = buildCommand()
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: params.outputPath) {
            try fileManager.removeItem(atPath: params.outputPath)
        }
        
        do {
            let result = try sh(
                command: "/bin/sh",
                parameters: ["-c"] + command,
                captureOutput: true,
                outputToConsole: true
            )
            
            if !result.isSucceeded {
                throw Errors.executionFailed("create_xcframework failed with exit code \(result.exitStatus): \(result.standardError)")
            }
        } catch {
            throw Errors.executionFailed("Failed to execute create_xcframework: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Validates the provided artifacts
    private func validateArtifacts() throws {
        switch params.binaries {
        case let .frameworks(frameworks):
            for framework in frameworks {
                guard framework.path.hasSuffix(".framework") else {
                    throw Errors.validationFailed("\(framework.path) doesn't end with '.framework'. Is this really a framework?")
                }

                guard FileManager.default.fileExists(atPath: framework.path) else {
                    throw Errors.validationFailed("Couldn't find framework at \(framework.path)")
                }

                var isDirectory: ObjCBool = false
                guard FileManager.default.fileExists(atPath: framework.path, isDirectory: &isDirectory), isDirectory.boolValue else {
                    throw Errors.validationFailed("\(framework.path) doesn't seem to be a framework")
                }

                if let dsym = framework.dsym {
                    guard FileManager.default.fileExists(atPath: dsym) else {
                        throw Errors.validationFailed("Couldn't find dSYM at \(dsym)")
                    }

                    var isDsymDirectory: ObjCBool = false
                    guard FileManager.default.fileExists(atPath: dsym, isDirectory: &isDsymDirectory), isDsymDirectory.boolValue else {
                        throw Errors.validationFailed("\(dsym) doesn't seem to be a dSYM archive")
                    }
                }
            }

        case let .libraries(libraries):
            for library in libraries {
                guard FileManager.default.fileExists(atPath: library.path) else {
                    throw Errors.validationFailed("Couldn't find library at \(library.path)")
                }

                if let headers = library.headers {
                    var isDirectory: ObjCBool = false
                    guard FileManager.default.fileExists(atPath: headers, isDirectory: &isDirectory), isDirectory.boolValue else {
                        throw Errors.validationFailed("\(headers) doesn't exist or is not a directory")
                    }
                }

                if let dsym = library.dsym {
                    guard FileManager.default.fileExists(atPath: dsym) else {
                        throw Errors.validationFailed("Couldn't find dSYM at \(dsym)")
                    }

                    var isDsymDirectory: ObjCBool = false
                    guard FileManager.default.fileExists(atPath: dsym, isDirectory: &isDsymDirectory), isDsymDirectory.boolValue else {
                        throw Errors.validationFailed("\(dsym) doesn't seem to be a dSYM archive")
                    }
                }
            }
        }
    }
    
    /// Builds the xcodebuild command for creating the xcframework
    /// - Returns: An array of command components
    private func buildCommand() -> [String] {
        var command = ["/usr/bin/xcrun", "xcodebuild", "-create-xcframework"]

        switch params.binaries {
        case let .frameworks(frameworks):
            for framework in frameworks {
                command.append("-framework")
                command.append("\"\(framework.path)\"")

                if let dsym = framework.dsym {
                    command.append("-debug-symbols")
                    command.append("\"\(dsym)\"")
                }
            }
        case let .libraries(libraries):
            for library in libraries {
                command.append("-library")
                command.append("\"\(library.path)\"")

                if let headers = library.headers {
                    command.append("-headers")
                    command.append("\"\(headers)\"")
                }

                if let dsym = library.dsym {
                    command.append("-debug-symbols")
                    command.append("\"\(dsym)\"")
                }
            }
        }

        command.append("-output")
        command.append("\"\(params.outputPath)\"")
        
        if params.allowInternalDistribution {
            command.append("-allow-internal-distribution")
        }
        
        return command
    }
}
