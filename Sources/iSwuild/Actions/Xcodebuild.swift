//  Created by Denis Malykh on 23.09.2025.

import Foundation
import BuildsDefinitions
import SwuildUtils

/// This action provides a comprehensive interface for building iOS and macOS projects
/// using the xcodebuild command-line tool. It supports various build configurations,
/// code signing options, archive/export settings, and formatting options.
///
/// The action is highly configurable through the ``XcodebuildParams`` struct which
/// organizes parameters into logical groups for better maintainability.
public struct Xcodebuild: Action {
    public let hint: String
    
    public enum Errors: Swift.Error, LocalizedError {
        case missingRequiredParameter(String)
        case executionFailed(String)

        public var errorDescription: String? {
            switch self {
            case .missingRequiredParameter(let parameter):
                return "Missing required parameter: \(parameter)"
            case .executionFailed(let message):
                return "Execution failed: \(message)"
            }
        }
    }

    // MARK: - Properties
    
    /// The parameters for configuring the xcodebuild action
    public let params: XcodebuildParams
    
    // MARK: - Initialization
    
    
    /// Initialize an Xcodebuild action with the specified parameters
    /// - Parameter params: The parameters to configure the xcodebuild action
    public init(hint: String = "-", params: XcodebuildParams) {
        self.hint = hint
        self.params = params
    }
    // MARK: - BuildsDefinitions.Action
    
    public static let name = "xcodebuild"
    public static let description = "Build iOS/macOS projects using xcodebuild"
    public static let authors = Author.defaultAuthors
    
    public static func isSupported(for platform: Platform) -> Bool {
        switch platform {
        case .iOS, .macOS:
            return true
        }
    }
    
    public func execute(context: Context, platform: Platform) async throws {
        guard params.project.workspace != nil || params.project.project != nil else {
            throw Xcodebuild.Errors.missingRequiredParameter("Either workspace or project must be specified")
        }
        
        let buildCommand = params.buildCommand()
        let commandString = buildCommand.joined(separator: " ")

        print("Executing xcodebuild command: \(commandString)")

        do {
            let logDirPath = params.output.buildlogPath
            var isDirectory: ObjCBool = false
            let logDirExists = FileManager.default.fileExists(atPath: logDirPath, isDirectory: &isDirectory)
            if !logDirExists {
                try FileManager.default.createDirectory(atPath: logDirPath, withIntermediateDirectories: true)
            } else if !isDirectory.boolValue {
                try FileManager.default.removeItem(atPath: logDirPath)
                try FileManager.default.createDirectory(atPath: logDirPath, withIntermediateDirectories: true)
            }

            let result = try sh(
                command: "/bin/sh",
                parameters: ["-c"] + buildCommand,
                captureOutput: true
            )
            
            if !result.isSucceeded {
                throw Xcodebuild.Errors.executionFailed("xcodebuild failed with exit code \(result.exitStatus): \(result.standardError)")
            }
            
            if params.archive.skipArchive != true && params.export.skipPackageIpa != true {
                try await exportArchive()
            }
        } catch {
            throw Xcodebuild.Errors.executionFailed("Failed to execute xcodebuild: \(error)")
        }
    }

    // MARK: - Private Methods
    
    private func exportArchive() async throws {
        guard params.archive.skipArchive != true else { return }
        
        let exportOptionsPath = try createExportOptionsPlist()
        
        var exportCommand = ["/usr/bin/xcrun"]
        exportCommand.append("xcodebuild")
        exportCommand.append("-exportArchive")
        exportCommand.append("-exportOptionsPlist")
        exportCommand.append(exportOptionsPath)
        exportCommand.append("-archivePath")
        exportCommand.append(params.archive.archivePath ?? params.defaultArchivePath())
        exportCommand.append("-exportPath")
        exportCommand.append(params.output.outputDirectory)
        
        if let toolchain = params.build.toolchain {
            exportCommand.append("-toolchain")
            exportCommand.append(toolchain)
        }
        
        if let exportXcargs = params.export.exportXcargs {
            exportCommand.append(contentsOf: exportXcargs.split(separator: " ").map(String.init))
        }
        
        if let xcargs = params.xcargs {
            exportCommand.append(contentsOf: xcargs.split(separator: " ").map(String.init))
        }
        
        let commandString = exportCommand.joined(separator: " ")

        print("Executing export command: \(commandString)")
        
        let result = try sh(
            command: "/bin/sh",
            parameters: ["-c", commandString],
            captureOutput: true
        )
        
        if !result.isSucceeded {
            throw Xcodebuild.Errors.executionFailed("Export failed with exit code \(result.exitStatus): \(result.standardError)")
        }
    }
    
    private func createExportOptionsPlist() throws -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let exportOptionsPath = tempDir.appendingPathComponent("export_options.plist").path
        
        var exportOptions: [String: Any] = [:]
        
        if let exportMethod = params.export.exportMethod {
            exportOptions["method"] = exportMethod
        }
        
        if let exportTeamId = params.export.exportTeamId {
            exportOptions["teamID"] = exportTeamId
        }
        
        if params.export.exportMethod == "app-store" {
            if let includeSymbols = params.export.includeSymbols {
                exportOptions["uploadSymbols"] = includeSymbols
            }
            if let includeBitcode = params.export.includeBitcode {
                exportOptions["uploadBitcode"] = includeBitcode
            }
        }
        
        if let installerCertName = params.codeSigning.installerCertName {
            exportOptions["installerSigningCertificate"] = installerCertName
        }
        
        if let customOptions = params.export.exportOptions {
            for (key, value) in customOptions {
                exportOptions[key] = value
            }
        }
        
        let plistData = try PropertyListSerialization.data(fromPropertyList: exportOptions, format: .xml, options: 0)
        try plistData.write(to: URL(fileURLWithPath: exportOptionsPath))
        
        return exportOptionsPath
    }
}
