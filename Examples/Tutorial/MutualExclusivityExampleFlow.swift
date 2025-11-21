//  Created by Assistant on 21.11.2025.

import BuildsDefinitions
import Foundation
import SwuildCore

public struct MutualExclusivityExampleFlow: Flow {
    public let name = "mutual_exclusivity_example"
    
    public let platforms: [Platform] = [
        .macOS(version: .any),
    ]
    
    public let description = "Example flow to test mutual exclusivity feature"
    
    public func actions(for context: Context, and platform: Platform) -> [any Action] {
        return [
            EchoAction(
                hint: "First action with mutual exclusivity key",
                mutualExclusivityKey: "unique-key-1",
                contentProvider: { "This is the first action with mutual exclusivity key" }
            ),
            
            EchoAction(
                hint: "Second action with same mutual exclusivity key",
                mutualExclusivityKey: "unique-key-1",
                contentProvider: { "This is the second action with the same mutual exclusivity key - should be skipped" }
            ),
            
            EchoAction(
                hint: "Third action with different mutual exclusivity key",
                mutualExclusivityKey: "unique-key-2",
                contentProvider: { "This is the third action with a different mutual exclusivity key" }
            ),
            
            EchoAction(
                hint: "Fourth action without mutual exclusivity key",
                contentProvider: { "This is the fourth action without a mutual exclusivity key" }
            ),
            
            ShellAction(
                hint: "Shell action with mutual exclusivity key",
                mutualExclusivityKey: "shell-key-1",
                command: "echo",
                arguments: [.raw(arg: "Shell action with mutual exclusivity key")]
            ),
            
            ShellAction(
                hint: "Another shell action with same mutual exclusivity key",
                mutualExclusivityKey: "shell-key-1",
                command: "echo",
                arguments: [.raw(arg: "Another shell action with same mutual exclusivity key - should be skipped")]
            ),
        ]
    }
}

@_cdecl("makeMutualExclusivityExampleFlow")
public func makeMutualExclusivityExampleFlow() -> UnsafeMutableRawPointer {
    flow { MutualExclusivityExampleFlow() }
}