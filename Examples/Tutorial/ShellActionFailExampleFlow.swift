//  Created by Denis Malykh on 2025-12-17.

import BuildsDefinitions
import Foundation
import SwuildCore

public struct ShellActionFailExampleFlow: Flow {
    public let name = "shell_action_fail_example"
    
    public let platforms: [Platform] = [
        .macOS(version: .any),
    ]
    
    public let description = "Example demonstrating the failOnNonZeroCode feature of ShellAction"
    
    public func actions(for context: Context, and platform: Platform) -> [any Action] {
        return [
            EchoAction(hint: "Demonstrating ShellAction with failOnNonZeroCode = false (default)", contentProvider: { .raw(arg: "=== ShellAction with failOnNonZeroCode = false ===") }),
            
            // This will not fail even though the command returns non-zero exit code
            ShellAction(
                hint: "Command that fails but won't cause action to fail",
                command: "ls",
                arguments: [.raw(arg: "/nonexistent_directory")],
                outputToConsole: true,
                failOnNonZeroCode: false
            ),
            
            EchoAction(hint: "Demonstrating ShellAction with failOnNonZeroCode = true", contentProvider: { .raw(arg: "=== ShellAction with failOnNonZeroCode = true ===") }),
            
            // This will fail because the command returns non-zero exit code and failOnNonZeroCode is true
            ShellAction(
                hint: "Command that fails and will cause action to fail",
                command: "ls",
                arguments: [.raw(arg: "/nonexistent_directory")],
                outputToConsole: true,
                failOnNonZeroCode: true
            ),
        ]
    }
}

@_cdecl("makeShellFailFlow")
public func makeShellFailFlow() -> UnsafeMutableRawPointer {
    flow { ShellActionFailExampleFlow() }
}