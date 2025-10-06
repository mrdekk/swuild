//  Created by Denis Malykh on 03.10.2025.

import BuildsDefinitions
import Foundation
import SwuildCore

// MARK: - Usage Examples

public enum FlowBuilderExamples {
    public static func makeExample() -> some Flow {
        return BasicFlow(
            name: "basic_flow_example",
            platforms: [.macOS(version: .any)],
            description: "A basic flow example using function builder"
        ) {
            EchoAction { .raw(arg: "Hello from function builder!") }
            ShellAction(command: "echo", arguments: [.raw(arg: "Simple command")])
        }
    }

    public static func makeSimpleFlow() -> some Flow {
        return BasicFlow(
            name: "simple_flow",
            platforms: [.macOS(version: .any)],
            description: "A simple flow example using function builder"
        ) {
            EchoAction { .raw(arg: "Hello from function builder!") }
            ShellAction(command: "echo", arguments: [.raw(arg: "Simple command")])
        }
    }
    
    public static func makeConditionalFlow() -> some Flow {
        return BasicFlow(
            name: "conditional_flow",
            platforms: [.macOS(version: .any)],
            description: "A flow with conditional actions"
        ) {
            EchoAction { .raw(arg: "Starting conditional flow") }
            
            // Use a fixed value instead of parameter
            let shouldListFiles = true
            
            if shouldListFiles {
                ShellAction(
                    command: "ls",
                    arguments: [.raw(arg: "-la")],
                    captureOutputToKey: "listing"
                )
                EchoAction { .key(key: "listing") }
            } else {
                EchoAction { .raw(arg: "Skipping file listing") }
            }
            
            EchoAction { .raw(arg: "Flow completed") }
        }
    }
    
    public static func makeBatchFlow() -> some Flow {
        return BasicFlow(
            name: "batch_flow",
            platforms: [.macOS(version: .any)],
            description: "A flow that executes a batch of commands"
        ) {
            EchoAction { .raw(arg: "Starting batch flow") }
            
            // Use fixed test commands instead of parameter
            let commands = ["echo Hello", "echo World", "ls -la"]
            
            for command in commands {
                ShellAction(command: command)
            }
            
            EchoAction { .raw(arg: "Batch flow completed") }
        }
    }
    
    public static func makeComplexFlow() -> some Flow {
        return BasicFlow(
            name: "complex_flow",
            platforms: [.macOS(version: .any), .iOS(version: .any)],
            description: "A complex flow demonstrating various function builder features"
        ) {
            // Simple actions
            EchoAction { .raw(arg: "Starting complex flow") }
            
            // Conditional actions based on platform
            #if os(macOS)
            ShellAction(command: "uname", arguments: [.raw(arg: "-a")], captureOutputToKey: "system_info")
            EchoAction { .key(key: "system_info") }
            #endif
            
            // Multiple actions in sequence
            ShellAction(command: "pwd", captureOutputToKey: "current_dir")
            EchoAction { .key(key: "current_dir") }
            
            // Conditional actions
            if true {  // This could be a runtime condition
                EchoAction { .raw(arg: "Condition is true") }
            }
            
            // Array of actions
            for i in 1...3 {
                EchoAction { .raw(arg: "Iteration \(i)") }
            }
            
            EchoAction { .raw(arg: "Complex flow completed") }
        }
    }
    
    public static func makeNestedConditionsFlow() -> some Flow {
        return BasicFlow(
            name: "nested_conditions_flow",
            platforms: [.macOS(version: .any)],
            description: "A flow with nested conditional actions"
        ) {
            EchoAction { .raw(arg: "Starting nested conditions flow") }
            
            #if os(macOS)
            if true {
                ShellAction(command: "echo", arguments: [.raw(arg: "On macOS and condition is true")])
                
                for i in 1...2 {
                    if i == 1 {
                        EchoAction { .raw(arg: "First iteration") }
                    } else {
                        EchoAction { .raw(arg: "Second iteration") }
                    }
                }
            }
            #endif
            
            EchoAction { .raw(arg: "Nested conditions flow completed") }
        }
    }
}
