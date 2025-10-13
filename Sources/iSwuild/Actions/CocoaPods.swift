//  Created by Denis Malykh on 24.09.2025.

import Foundation
import BuildsDefinitions
import SwuildUtils

/// This action provides an interface for running `pod install` to manage
/// CocoaPods dependencies in iOS and macOS projects. It supports various
/// options for customizing the pod installation process.
///
/// The action is configurable through the ``CocoaPodsParams`` struct which
/// contains all the parameters needed to customize the pod installation.
public struct CocoaPods: Action {
    public enum Errors: Error, LocalizedError {
        case cocoapodsNotInstalled
        case executionFailed(String)

        public var errorDescription: String? {
            switch self {
            case .cocoapodsNotInstalled:
                return "CocoaPods is not installed. Please install it with `gem install cocoapods`"
            case .executionFailed(let message):
                return "Execution failed: \(message)"
            }
        }
    }

    // MARK: - Properties
    
    /// The parameters for configuring the CocoaPods action
    public let params: CocoaPodsParams
    
    // MARK: - Initialization
    
    /// Initialize a CocoaPods action with the specified parameters
    /// - Parameter params: The parameters to configure the CocoaPods action
    public init(params: CocoaPodsParams) {
        self.params = params
    }
    
    // MARK: - BuildsDefinitions.Action
    
    public static let name = "cocoapods"
    public static let description = "Runs `pod install` for the project"
    public static let authors = Author.defaultAuthors
    
    public static func isSupported(for platform: Platform) -> Bool {
        switch platform {
        case .iOS, .macOS:
            return true
        }
    }
    
    public func execute(context: Context, platform: Platform) async throws {
        do {
            try sh(command: "pod", "--version", captureOutput: true)
        } catch {
            throw CocoaPods.Errors.cocoapodsNotInstalled
        }
        
        let buildCommand = params.buildCommand()
        let commandString = buildCommand.joined(separator: " ")

        print("Executing cocoapods command: \(commandString)")

        do {
            let result = try sh(
                command: "/bin/sh",
                parameters: ["-c", commandString],
                captureOutput: true,
                currentDirectoryPath: params.workingDirectory
            )
            
            if result.isSucceeded {
                return
            }

            // If repo update is not already tried and it's enabled, try with --repo-update
            guard !params.repoUpdate && params.tryRepoUpdateOnError else {
                throw CocoaPods.Errors.executionFailed("CocoaPods failed with exit code \(result.exitStatus): \(result.standardError)")
            }

            let retryCommand = params.buildCommand(withRepoUpdate: true)
            let retryCommandString = retryCommand.joined(separator: " ")

            let retryResult = try sh(
                command: "/bin/sh",
                parameters: ["-c", retryCommandString],
                captureOutput: true,
                currentDirectoryPath: params.workingDirectory
            )

            if !retryResult.isSucceeded {
                throw CocoaPods.Errors.executionFailed("CocoaPods failed with exit code \(retryResult.exitStatus): \(retryResult.standardError)")
            }
        } catch {
            throw CocoaPods.Errors.executionFailed("Failed to execute CocoaPods: \(error)")
        }
    }
}
