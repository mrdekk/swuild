//  Created by Denis Malykh on 02.12.2025.

import Foundation

/// This struct contains all the parameters needed to configure a create_xcframework action,
/// organized into logical groups for better maintainability and clarity.
public struct CreateXcframeworkParams {
    
    // MARK: - Framework Structures
    
    /// A framework with optional dSYM information
    public struct Framework {
        /// Path to the framework
        public let path: String
        
        /// Path to the dSYM file (optional)
        public let dsym: String?

        public init(path: String, dsym: String? = nil) {
            self.path = path
            self.dsym = dsym
        }
    }
    
    /// A library with optional headers and dSYM information
    public struct Library {
        /// Path to the library
        public let path: String
        
        /// Path to the headers directory (optional)
        public let headers: String?
        
        /// Path to the dSYM file (optional)
        public let dsym: String?
        
        public init(path: String, headers: String? = nil, dsym: String? = nil) {
            self.path = path
            self.headers = headers
            self.dsym = dsym
        }
    }

    /// Action support either frameworks or libraries, not both
    /// So a way to organize provided dependencies
    public enum Binaries {
        case frameworks([Framework])
        case libraries([Library])
    }

    // MARK: - Artifact Configuration
    
    /// Binaries to add to the target xcframework
    public let binaries: Binaries

    // MARK: - Output Configuration
    
    /// The path to write the xcframework to
    public let outputPath: String

    /// Specifies that the created xcframework contains information not suitable for public distribution
    public let allowInternalDistribution: Bool
    
    // MARK: - Initialization
    
    public init(
        binaries: Binaries,
        outputPath: String,
        allowInternalDistribution: Bool = false
    ) {
        self.binaries = binaries
        self.outputPath = outputPath
        self.allowInternalDistribution = allowInternalDistribution
    }
    
    /// Convenience initializer for frameworks with paths only
    public init(
        frameworkPaths: [String],
        outputPath: String,
        allowInternalDistribution: Bool = false
    ) {
        self.binaries = .frameworks(frameworkPaths.map { Framework(path: $0) })
        self.outputPath = outputPath
        self.allowInternalDistribution = allowInternalDistribution
    }
    
    /// Convenience initializer for libraries with paths only
    public init(
        libraryPaths: [String],
        outputPath: String,
        allowInternalDistribution: Bool = false
    ) {
        self.binaries = .libraries(libraryPaths.map { Library(path: $0) })
        self.outputPath = outputPath
        self.allowInternalDistribution = allowInternalDistribution
    }
}
