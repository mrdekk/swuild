//  Created by Denis Malykh on 02.12.2025.

import Foundation

/// This struct contains all the parameters needed to configure a Zip action
public struct ZipParams {
    /// Path to the directory or file to be zipped
    public let path: String
    
    /// The name of the resulting zip file
    public let outputPath: String?
    
    /// Enable verbose output of zipped file
    public let verbose: Bool
    
    /// Encrypt the contents of the zip archive using a password
    public let password: String?
    
    /// Store symbolic links as such in the zip archive
    public let symlinks: Bool
    
    /// Array of paths or patterns to include
    public let include: [String]
    
    /// Array of paths or patterns to exclude
    public let exclude: [String]
    
    /// The working directory for the zip command
    public let workingDirectory: String?
    
    // MARK: - Initialization
    
    public init(
        path: String,
        outputPath: String? = nil,
        verbose: Bool = true,
        password: String? = nil,
        symlinks: Bool = false,
        include: [String] = [],
        exclude: [String] = [],
        workingDirectory: String? = nil
    ) {
        self.path = path
        self.outputPath = outputPath
        self.verbose = verbose
        self.password = password
        self.symlinks = symlinks
        self.include = include
        self.exclude = exclude
        self.workingDirectory = workingDirectory
    }
}

extension ZipParams {
    internal func buildCommand(fileManager: FileManager = .default) throws -> (command: [String], sourceDirectory: String) {
        // The 'zip' command archives relative to the working directory
        // We need to determine the correct working directory and output path
        
        let actualWorkingDirectory = workingDirectory ?? fileManager.currentDirectoryPath
        let sourcePath = path.hasPrefix("/") ? path : "\(actualWorkingDirectory)/\(path)"
        
        let actualOutputPath: String = if let outputPath = self.outputPath {
            outputPath.hasPrefix("/") ? outputPath : "\(actualWorkingDirectory)/\(outputPath)"
        } else {
            sourcePath.hasSuffix(".zip") ? sourcePath : "\(sourcePath).zip"
        }
        
        let outputDir = URL(fileURLWithPath: actualOutputPath).deletingLastPathComponent().path
        try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

        var command = ["zip"]
        
        var options = verbose ? "r" : "rq"
        if symlinks {
            options += "y"
        }
        command += ["-\(options)"]
        
        if let password = self.password {
            command += ["-P", password]
        }
        
        command += [actualOutputPath]
        
        let sourceBaseName = URL(fileURLWithPath: sourcePath).lastPathComponent
        command += [sourceBaseName]
        
        if !include.isEmpty {
            command += ["-i"]
            command += include.map { pattern in
                "\(sourceBaseName)/\(pattern)"
            }
        }
        
        if !exclude.isEmpty {
            command += ["-x"]
            command += exclude.map { pattern in
                "\(sourceBaseName)/\(pattern)"
            }
        }
        
        let sourceDirectory = URL(fileURLWithPath: sourcePath).deletingLastPathComponent().path
        
        return (command, sourceDirectory)
    }
}
