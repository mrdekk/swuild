//  Created by Denis Malykh on 02.12.2025.

import Foundation
import BuildsDefinitions
import SwuildUtils

/// This action provides an interface for creating zip archives from files or directories.
/// It supports various options for customizing the zip creation process.
///
/// The action is configurable through the ``ZipParams`` struct which
/// contains all the parameters needed to customize the zip creation.
public struct ZipAction: Action {
    public let hint: String
    
    public enum Errors: Error, LocalizedError {
        case sourceFileNotExists
        case zipNotInstalled
        case executionFailed(String)
        
        public var errorDescription: String? {
            switch self {
            case .sourceFileNotExists:
                return "Source file or directory does not exist"
            case .zipNotInstalled:
                return "zip command is not installed"
            case .executionFailed(let message):
                return "Execution failed: \(message)"
            }
        }
    }
    
    // MARK: - Properties
    
    /// The parameters for configuring the Zip action
    public let params: ZipParams
    
    // MARK: - Initialization
    
    /// Initialize a Zip action with the specified parameters
    /// - Parameter params: The parameters to configure the Zip action
    public init(hint: String = "-", params: ZipParams) {
        self.hint = hint
        self.params = params
    }
    
    // MARK: - BuildsDefinitions.Action
    
    public static let name = "zip"
    public static let description = "Compress a file or folder to a zip archive"
    public static let authors = Author.defaultAuthors
    
    public static func isSupported(for platform: Platform) -> Bool {
        switch platform {
        case .macOS: true
        case .iOS: false
        }
    }
    
    public func execute(context: Context, platform: Platform) async throws {
        let fileManager = FileManager.default

        do {
            try sh(command: "which", "zip", captureOutput: true)
        } catch {
            throw Errors.zipNotInstalled
        }
        
        let actualWorkingDirectory = params.workingDirectory ?? fileManager.currentDirectoryPath
        let sourcePath = params.path.hasPrefix("/") ? params.path : "\(actualWorkingDirectory)/\(params.path)"
        
        guard fileManager.fileExists(atPath: sourcePath) else {
            throw Errors.sourceFileNotExists
        }
        
        let (command, sourceDirectory) = try params.buildCommand()
        
        print("Executing zip command: \(command.joined(separator: " "))")
        print("Working directory: \(sourceDirectory)")
        
        do {
            let result = try sh(
                command: command,
                captureOutput: true,
                outputToConsole: true,
                currentDirectoryPath: sourceDirectory
            )
            
            if result.isSucceeded {
                print("Successfully generated zip file")
                return
            }
            
            throw Errors.executionFailed("zip failed with exit code \(result.exitStatus): \(result.standardError)")
        } catch {
            throw Errors.executionFailed("Failed to execute zip: \(error)")
        }
    }
}
