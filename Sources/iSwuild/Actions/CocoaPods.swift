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
    public let hint: String
    
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
    public let outputToConsole: Bool
    
    // MARK: - Initialization
    
    
    /// Initialize a CocoaPods action with the specified parameters
    /// - Parameter params: The parameters to configure the CocoaPods action
    public init(
        hint: String = "-",
        params: CocoaPodsParams,
        outputToConsole: Bool = false
    ) {
        self.hint = hint
        self.params = params
        self.outputToConsole = outputToConsole
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
            var shellCommand = params.useShellCommand
            shellCommand.append(commandString)
            let result = try sh(
                command: shellCommand.first!,
                parameters: Array(shellCommand[1...]),
                captureOutput: true,
                outputToConsole: outputToConsole,
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

            var retryShellCommand = params.useShellCommand
            retryShellCommand.append(retryCommandString)
            let retryResult = try sh(
                command: retryShellCommand.first!,
                parameters: Array(retryShellCommand[1...]),
                captureOutput: true,
                outputToConsole: outputToConsole,
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
