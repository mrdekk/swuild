//  Created by Denis Malykh on 03.12.2024.

import Foundation
import BuildsDefinitions
import SwuildUtils

public struct Cocoapods: Action {

    public enum Errors: Error {
        case cocoapodsFailed(output: String)
    }

    public let useBundler: Bool
    public let clean: Bool
    public let updatePodspecRepository: Bool
    public let verbose: Bool
    public let workingDirectory: String

    public init(
        useBundler: Bool,
        clean: Bool,
        updatePodspecRepository: Bool,
        verbose: Bool,
        workingDirectory: String = FileManager.default.currentDirectoryPath
    ) {
        self.useBundler = useBundler
        self.clean = clean
        self.updatePodspecRepository = updatePodspecRepository
        self.verbose = verbose
        self.workingDirectory = workingDirectory
    }

    // MARK: - BuildsDefinitions.Action

    public static let name = "cocoapods"

    public static let description = "Action to use cocoapods to manage pod installation"

    public static let authors = Author.defaultAuthors

    public static func isSupported(for platform: Platform) -> Bool {
        switch platform {
        case .iOS, .macOS: return true
        }
    }

    public func execute(context: Context, platform: Platform) async throws {
        var cmd = [String]()
        
        if useBundler {
            cmd += ["bundle", "exec"]
        }
        cmd += ["pod", "install"]
        if !clean {
            cmd += ["--no-clean"]
        }
        if verbose {
            cmd += ["--verbose"]
        }
        if updatePodspecRepository {
            cmd += ["--repo-update"]
        }

        do {
            let result = try sh(
                command: cmd,
                captureOutput: true,
                currentDirectoryPath: workingDirectory
            )
            if !result.isSucceeded {
                throw Errors.cocoapodsFailed(output: result.standardError)
            }
        } catch {
            throw error
        }
    }
}
