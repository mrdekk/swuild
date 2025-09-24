//  Created by Denis Malykh on 23.09.2025.

import Foundation

/// This struct contains all the parameters needed to configure an xcodebuild action,
/// organized into logical groups for better maintainability and clarity.
public struct XcodebuildParams {
    
    // MARK: - Project Configuration
    
    /// Configuration for project/workspace settings
    public struct ProjectConfig {
        /// Path to the workspace file (e.g. "MyApp.xcworkspace")
        public let workspace: String?
        
        /// Path to the project file (e.g. "MyApp.xcodeproj")
        public let project: String?
        
        /// The project's scheme. Make sure it's marked as `Shared`
        public let scheme: String?
        
        /// The configuration to use when building the app.
        public let configuration: String?
        
        public init(
            workspace: String? = nil,
            project: String? = nil,
            scheme: String? = nil,
            configuration: String? = nil
        ) {
            self.workspace = workspace
            self.project = project
            self.scheme = scheme
            self.configuration = configuration
        }
    }
    
    // MARK: - Build Configuration
    
    /// Configuration for build settings
    public struct BuildConfig {
        /// Should the project be cleaned before building it?
        public let clean: Bool
        
        /// The directory in which the archive should be stored in
        public let buildPath: String?
        
        /// The directory where built products and other derived data will go
        public let derivedDataPath: String?
        
        /// The SDK that should be used for building the application
        public let sdk: String?
        
        /// The toolchain that should be used for building the application
        public let toolchain: String?
        
        /// Use a custom destination for building the app
        public let destination: String?
        
        /// Lets xcodebuild use system's scm configuration
        public let useSystemScm: Bool
        
        public init(
            clean: Bool = false,
            buildPath: String? = nil,
            derivedDataPath: String? = nil,
            sdk: String? = nil,
            toolchain: String? = nil,
            destination: String? = nil,
            useSystemScm: Bool = false
        ) {
            self.clean = clean
            self.buildPath = buildPath
            self.derivedDataPath = derivedDataPath
            self.sdk = sdk
            self.toolchain = toolchain
            self.destination = destination
            self.useSystemScm = useSystemScm
        }
    }
    
    // MARK: - Archive Configuration
    
    /// Configuration for archive settings
    public struct ArchiveConfig {
        /// The path to the created archive
        public let archivePath: String?
        
        /// After building, don't archive, effectively not including -archivePath param
        public let skipArchive: Bool?
        
        /// Export ipa from previously built xcarchive. Uses archive_path as source
        public let skipBuildArchive: Bool?
        
        /// Should an Xcode result bundle be generated in the output directory
        public let resultBundle: Bool
        
        /// Path to the result bundle directory to create. Ignored if `resultBundle` is false
        public let resultBundlePath: String?
        
        public init(
            archivePath: String? = nil,
            skipArchive: Bool? = nil,
            skipBuildArchive: Bool? = nil,
            resultBundle: Bool = false,
            resultBundlePath: String? = nil
        ) {
            self.archivePath = archivePath
            self.skipArchive = skipArchive
            self.skipBuildArchive = skipBuildArchive
            self.resultBundle = resultBundle
            self.resultBundlePath = resultBundlePath
        }
    }
    
    // MARK: - Code Signing Configuration
    
    /// Configuration for code signing settings
    public struct CodeSigningConfig {
        /// The name of the code signing identity to use. It has to match the name exactly
        public let codesigningIdentity: String?
        
        /// Build without codesigning
        public let skipCodesigning: Bool?
        
        /// Full name of 3rd Party Mac Developer Installer or Developer ID Installer certificate
        public let installerCertName: String?
        
        public init(
            codesigningIdentity: String? = nil,
            skipCodesigning: Bool? = nil,
            installerCertName: String? = nil
        ) {
            self.codesigningIdentity = codesigningIdentity
            self.skipCodesigning = skipCodesigning
            self.installerCertName = installerCertName
        }
    }
    
    // MARK: - Export Configuration
    
    /// Configuration for export settings
    public struct ExportConfig {
        /// Method used to export the archive
        public let exportMethod: String?
        
        /// Path to an export options plist or a hash with export options
        public let exportOptions: [String: Any]?
        
        /// Pass additional arguments to xcodebuild for the package phase
        public let exportXcargs: String?
        
        /// Optional: Sometimes you need to specify a team id when exporting the ipa file
        public let exportTeamId: String?
        
        /// Should we skip packaging the ipa?
        public let skipPackageIpa: Bool
        
        /// Should we skip packaging the pkg?
        public let skipPackagePkg: Bool
        
        /// Should the ipa file include symbols?
        public let includeSymbols: Bool?
        
        /// Should the ipa file include bitcode?
        public let includeBitcode: Bool?
        
        public init(
            exportMethod: String? = nil,
            exportOptions: [String: Any]? = nil,
            exportXcargs: String? = nil,
            exportTeamId: String? = nil,
            skipPackageIpa: Bool = false,
            skipPackagePkg: Bool = false,
            includeSymbols: Bool? = nil,
            includeBitcode: Bool? = nil
        ) {
            self.exportMethod = exportMethod
            self.exportOptions = exportOptions
            self.exportXcargs = exportXcargs
            self.exportTeamId = exportTeamId
            self.skipPackageIpa = skipPackageIpa
            self.skipPackagePkg = skipPackagePkg
            self.includeSymbols = includeSymbols
            self.includeBitcode = includeBitcode
        }
    }
    
    // MARK: - Output Configuration
    
    /// Configuration for output settings
    public struct OutputConfig {
        /// The directory in which the ipa file should be stored in
        public let outputDirectory: String
        
        /// The name of the resulting ipa file
        public let outputName: String?
        
        /// The directory where to store the build log
        public let buildlogPath: String
        
        public init(
            outputDirectory: String = ".",
            outputName: String? = nil,
            buildlogPath: String = "\(NSHomeDirectory())/Library/Logs/fastlane/gym"
        ) {
            self.outputDirectory = outputDirectory
            self.outputName = outputName
            self.buildlogPath = buildlogPath
        }
    }
    
    // MARK: - Formatting Configuration
    
    /// Configuration for formatting and logging settings
    public struct FormattingConfig {
        /// Hide all information that's not necessary while building
        public let silent: Bool
        
        /// xcodebuild formatter to use (ex: 'xcbeautify', 'xcbeautify --quieter', 'xcpretty')
        public let xcodebuildFormatter: String?
        
        /// Create a build timing summary
        public let buildTimingSummary: Bool?
        
        /// Suppress the output of xcodebuild to stdout. Output is still saved in buildlogPath
        public let suppressXcodeOutput: Bool?
        
        /// Disable xcpretty formatting of build output
        public let disableXcpretty: Bool?
        
        /// Use the test (RSpec style) format for build output
        public let xcprettyTestFormat: Bool?
        
        /// A custom xcpretty formatter to use
        public let xcprettyFormatter: String?
        
        /// Have xcpretty create a JUnit-style XML report at the provided path
        public let xcprettyReportJunit: String?
        
        /// Have xcpretty create a simple HTML report at the provided path
        public let xcprettyReportHtml: String?
        
        /// Have xcpretty create a JSON compilation database at the provided path
        public let xcprettyReportJson: String?
        
        /// Have xcpretty use unicode encoding when reporting builds
        public let xcprettyUtf: Bool?
        
        /// Analyze the project build time and store the output in 'culprits.txt' file
        public let analyzeBuildTime: Bool?
        
        public init(
            silent: Bool = false,
            xcodebuildFormatter: String? = nil,
            buildTimingSummary: Bool? = nil,
            suppressXcodeOutput: Bool? = nil,
            disableXcpretty: Bool? = nil,
            xcprettyTestFormat: Bool? = nil,
            xcprettyFormatter: String? = nil,
            xcprettyReportJunit: String? = nil,
            xcprettyReportHtml: String? = nil,
            xcprettyReportJson: String? = nil,
            xcprettyUtf: Bool? = nil,
            analyzeBuildTime: Bool? = nil
        ) {
            self.silent = silent
            self.xcodebuildFormatter = xcodebuildFormatter
            self.buildTimingSummary = buildTimingSummary
            self.suppressXcodeOutput = suppressXcodeOutput
            self.disableXcpretty = disableXcpretty
            self.xcprettyTestFormat = xcprettyTestFormat
            self.xcprettyFormatter = xcprettyFormatter
            self.xcprettyReportJunit = xcprettyReportJunit
            self.xcprettyReportHtml = xcprettyReportHtml
            self.xcprettyReportJson = xcprettyReportJson
            self.xcprettyUtf = xcprettyUtf
            self.analyzeBuildTime = analyzeBuildTime
        }
    }
    
    // MARK: - Package Configuration
    
    /// Configuration for Swift Package Manager settings
    public struct PackageConfig {
        /// Sets a custom path for Swift Package Manager dependencies
        public let clonedSourcePackagesPath: String?
        
        /// Skips resolution of Swift Package Manager dependencies
        public let skipPackageDependenciesResolution: Bool
        
        /// Prevents packages from automatically being resolved to versions other than those recorded in the Package.resolved file
        public let disablePackageAutomaticUpdates: Bool
        
        /// Lets xcodebuild use a specified package authorization provider (keychain|netrc)
        public let packageAuthorizationProvider: String?
        
        public init(
            clonedSourcePackagesPath: String? = nil,
            skipPackageDependenciesResolution: Bool = false,
            disablePackageAutomaticUpdates: Bool = false,
            packageAuthorizationProvider: String? = nil
        ) {
            self.clonedSourcePackagesPath = clonedSourcePackagesPath
            self.skipPackageDependenciesResolution = skipPackageDependenciesResolution
            self.disablePackageAutomaticUpdates = disablePackageAutomaticUpdates
            self.packageAuthorizationProvider = packageAuthorizationProvider
        }
    }
    
    // MARK: - Main Properties
    public let project: ProjectConfig
    public let build: BuildConfig
    public let archive: ArchiveConfig
    public let codeSigning: CodeSigningConfig
    public let export: ExportConfig
    public let output: OutputConfig
    public let formatting: FormattingConfig
    public let package: PackageConfig
    
    // MARK: - Additional Properties
    public let xcargs: String?
    public let xcconfig: String?
    public let skipProfileDetection: Bool
    public let xcodebuildCommand: String
    public let catalystPlatform: String?
    
    // MARK: - Hierarchical Initialization
    
    public init(
        project: ProjectConfig,
        build: BuildConfig,
        archive: ArchiveConfig,
        codeSigning: CodeSigningConfig,
        export: ExportConfig,
        output: OutputConfig,
        formatting: FormattingConfig,
        package: PackageConfig,
        xcargs: String? = nil,
        xcconfig: String? = nil,
        skipProfileDetection: Bool = false,
        xcodebuildCommand: String = "xcodebuild",
        catalystPlatform: String? = nil
    ) {
        self.project = project
        self.build = build
        self.archive = archive
        self.codeSigning = codeSigning
        self.export = export
        self.output = output
        self.formatting = formatting
        self.package = package
        self.xcargs = xcargs
        self.xcconfig = xcconfig
        self.skipProfileDetection = skipProfileDetection
        self.xcodebuildCommand = xcodebuildCommand
        self.catalystPlatform = catalystPlatform
    }
}

extension XcodebuildParams {
    internal func buildCommand() -> [String] {
        var buildCommand = ["set -o pipefail &&"]
        buildCommand.append(xcodebuildCommand)
        
        if let workspace = project.workspace {
            buildCommand.append("-workspace")
            buildCommand.append(workspace)
        } else if let projectPath = project.project {
            buildCommand.append("-project")
            buildCommand.append(projectPath)
        }
        
        if let scheme = project.scheme {
            buildCommand.append("-scheme")
            buildCommand.append(scheme)
        }
        
        if let configuration = project.configuration {
            buildCommand.append("-configuration")
            buildCommand.append(configuration)
        }
        
        if let sdk = build.sdk {
            buildCommand.append("-sdk")
            buildCommand.append(sdk)
        }
        
        if let toolchain = build.toolchain {
            buildCommand.append("-toolchain")
            buildCommand.append(toolchain)
        }
        
        if let destination = build.destination {
            buildCommand.append("-destination")
            buildCommand.append(destination)
        }
        
        if archive.skipArchive != true {
            let archivePath = self.archive.archivePath ?? defaultArchivePath()
            buildCommand.append("-archivePath")
            buildCommand.append(archivePath)
        }
        
        if archive.resultBundle, let resultBundlePath = archive.resultBundlePath {
            buildCommand.append("-resultBundlePath")
            buildCommand.append(resultBundlePath)
        }
        
        if formatting.buildTimingSummary == true {
            buildCommand.append("-showBuildTimingSummary")
        }
        
        if build.useSystemScm {
            buildCommand.append("-scmProvider")
            buildCommand.append("system")
        }
        
        if let xcargs = xcargs {
            buildCommand.append(contentsOf: xcargs.split(separator: " ").map(String.init))
        }
        
        if build.clean {
            buildCommand.append("clean")
        }
        
        if archive.skipArchive == true {
            buildCommand.append("build")
        } else {
            buildCommand.append("archive")
        }
        
        if codeSigning.skipCodesigning == true {
            buildCommand.append("CODE_SIGN_IDENTITY=''")
            buildCommand.append("CODE_SIGNING_REQUIRED=NO")
            buildCommand.append("CODE_SIGN_ENTITLEMENTS=''")
            buildCommand.append("CODE_SIGNING_ALLOWED=NO")
        } else if let codesigningIdentity = codeSigning.codesigningIdentity {
            buildCommand.append("CODE_SIGN_IDENTITY=\(codesigningIdentity)")
        }
        
        let logPath = "\(output.buildlogPath)/\(logFileName())"
        buildCommand.append("|")
        buildCommand.append("tee")
        buildCommand.append(logPath)
        
        if let formatter = formatting.xcodebuildFormatter, !formatter.isEmpty, formatting.disableXcpretty != true {
            buildCommand.append("|")
            buildCommand.append(formatter)
        }
        
        if formatting.suppressXcodeOutput == true {
            buildCommand.append(">")
            buildCommand.append("/dev/null")
        }
        
        return buildCommand
    }
    
    internal func defaultArchivePath() -> String {
        let buildPath = build.buildPath ?? FileManager.default.temporaryDirectory.path
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let fileName = [output.outputName, formatter.string(from: Date())].compactMap { $0 }.joined(separator: " ")
        return "\(buildPath)/\(fileName).xcarchive"
    }
    
    internal func logFileName() -> String {
        let appName = project.scheme ?? "app"
        return "\(appName).log"
    }
}
