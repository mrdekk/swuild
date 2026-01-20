//  Created by Denis Malykh on 24.09.2025.

import Foundation
import SwuildUtils

/// This struct contains all the parameters needed to configure a CocoaPods action
public struct CocoaPodsParams {    
    /// Add `--repo-update` flag to `pod install` command
    public let repoUpdate: Bool
    
    /// Execute a full pod installation ignoring the content of the project cache
    public let cleanInstall: Bool
    
    /// Execute command without logging output
    public let silent: Bool
    
    /// Show more debugging information
    public let verbose: Bool
    
    /// Show output with ANSI codes
    public let ansi: Bool
    
    /// Use bundle exec when there is a Gemfile presented
    public let useBundleExec: Bool
    
    /// Explicitly specify the path to the Cocoapods' Podfile
    public let podfilePath: String?
    
    /// Retry with --repo-update if action was finished with error
    public let tryRepoUpdateOnError: Bool
    
    /// Disallow any changes to the Podfile or the Podfile.lock during installation
    public let deployment: Bool
    
    /// Allows CocoaPods to run as root
    public let allowRoot: Bool
    
    /// The working directory for the pod command
    public let workingDirectory: String?
    
    /// Shell command to use for execution (e.g., ["/bin/bash", "-l", "-c"])
    /// Empty array means direct execution
    public let useShellCommand: [String]

    // MARK: - Initialization
    
    public init(
        repoUpdate: Bool = false,
        cleanInstall: Bool = false,
        silent: Bool = false,
        verbose: Bool = false,
        ansi: Bool = true,
        useBundleExec: Bool = true,
        podfilePath: String? = nil,
        tryRepoUpdateOnError: Bool = false,
        deployment: Bool = false,
        allowRoot: Bool = false,
        workingDirectory: String? = nil,
        useShellCommand: [String] = ["/bin/sh", "-c"]
    ) {
        self.repoUpdate = repoUpdate
        self.cleanInstall = cleanInstall
        self.silent = silent
        self.verbose = verbose
        self.ansi = ansi
        self.useBundleExec = useBundleExec
        self.podfilePath = podfilePath
        self.tryRepoUpdateOnError = tryRepoUpdateOnError
        self.deployment = deployment
        self.allowRoot = allowRoot
        self.workingDirectory = workingDirectory
        self.useShellCommand = useShellCommand
    }
}

extension CocoaPodsParams {
    internal func buildCommand(withRepoUpdate forceRepoUpdate: Bool = false) -> [String] {
        var cmd = [String]()
        
        if let podfilePath = self.podfilePath {
            let podfileFolder: String
            if podfilePath.hasSuffix("Podfile") {
                podfileFolder = URL(fileURLWithPath: podfilePath).deletingLastPathComponent().path
            } else {
                podfileFolder = podfilePath
            }
            cmd += ["cd", "'\(podfileFolder)'", "&&"]
        }
        
        if useBundleExec && FileManager.default.fileExists(atPath: "Gemfile") {
            cmd += ["bundle", "exec"]
        }
        
        cmd += ["pod", "install"]
                
        if cleanInstall {
            cmd += ["--clean-install"]
        }
        
        if allowRoot {
            cmd += ["--allow-root"]
        }
        
        if repoUpdate || forceRepoUpdate {
            cmd += ["--repo-update"]
        }
        
        if silent {
            cmd += ["--silent"]
        }
        
        if verbose {
            cmd += ["--verbose"]
        }
        
        if !ansi {
            cmd += ["--no-ansi"]
        }
        
        if deployment {
            cmd += ["--deployment"]
        }
        
        return cmd
    }
}
