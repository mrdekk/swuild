//  Created by Denis Malykh on 05.12.2025.

import Foundation
import BuildsDefinitions
import SwuildUtils

/// This action provides functionality for changing the Xcode path to use.
/// Useful for beta versions of Xcode or when working with multiple Xcode installations.
///
/// The action sets the DEVELOPER_DIR environment variable to point to the specified Xcode version.
public struct XcodeSelect: Action {
    public let hint: String
    
    public enum Errors: Swift.Error, LocalizedError {
        case missingRequiredParameter(String)
        case pathDoesNotExist(String)
        
        public var errorDescription: String? {
            switch self {
            case .missingRequiredParameter(let parameter):
                return "Missing required parameter: \(parameter)"
            case .pathDoesNotExist(let path):
                return "Path '\(path)' doesn't exist"
            }
        }
    }
    
    // MARK: - Properties
    
    /// The parameters for configuring the xcode_select action
    public let params: XcodeSelectParams
    
    // MARK: - Initialization
    
    /// Initialize an XcodeSelect action with the specified parameters
    /// - Parameter params: The parameters to configure the xcode_select action
    public init(hint: String = "-", params: XcodeSelectParams) {
        self.hint = hint
        self.params = params
    }
    
    // MARK: - BuildsDefinitions.Action
    
    public static let name = "xcode_select"
    public static let description = "Change the xcode-path to use. Useful for beta versions of Xcode"
    public static let authors = Author.defaultAuthors
    
    public static func isSupported(for platform: Platform) -> Bool {
        switch platform {
        case .iOS, .macOS:
            return true
        }
    }
    
    public func execute(context: Context, platform: Platform) async throws {
        guard !params.xcodePath.isEmpty else {
            throw Errors.missingRequiredParameter("Path to Xcode application required (e.g. `xcode_select(\"/Applications/Xcode.app\")`)")
        }
        
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: params.xcodePath, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw Errors.pathDoesNotExist(params.xcodePath)
        }
        
        print("Setting Xcode version to \(params.xcodePath) for all build steps")
        
        let developerDir = "\(params.xcodePath)/Contents/Developer"
        
        // Store the DEVELOPER_DIR in the context so subsequent actions can use it
        // We'll use a specific key that other actions can look for
        let developerDirOption = StringOption(defaultValue: developerDir)
        context.put(for: "DEVELOPER_DIR", option: developerDirOption)
        
        // Also set it in the current process environment
        setenv("DEVELOPER_DIR", developerDir, 1)
    }
}
