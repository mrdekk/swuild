//  Created by Denis Malykh on 03.10.2025.

import BuildsDefinitions
import Foundation
import SwuildCore

// MARK: - Usage Examples

public enum SampleErrors: Error {
    case oops
}

public enum FlowBuilderExamples {
    public static func makeThrowingFlow() -> some Flow {
        return BasicFlow(
            name: "throwing_flow",
            platforms: [.macOS(version: .any)],
            description: "A basic throwing flow",
        ) { _, _ in
            throw SampleErrors.oops
        }
    }

    public static func makeExample() -> some Flow {
        return BasicFlow(
            name: "basic_flow_example",
            platforms: [.macOS(version: .any)],
            description: "A basic flow example using function builder"
        ) { _, _ in
            EchoAction(hint: "Greeting from function builder", contentProvider: { .raw(arg: "Hello from function builder!") })
            ShellAction(hint: "Execute simple command", command: "echo", arguments: [.raw(arg: "Simple command")], outputToConsole: true)
        }
    }

    public static func makeSimpleFlow() -> some Flow {
        return BasicFlow(
            name: "simple_flow",
            platforms: [.macOS(version: .any)],
            description: "A simple flow example using function builder"
        ) { _, _ in
            EchoAction(hint: "Greeting from function builder", contentProvider: { .raw(arg: "Hello from function builder!") })
            ShellAction(hint: "Execute simple command", command: "echo", arguments: [.raw(arg: "Simple command")], outputToConsole: true)
        }
    }
    
    public static func makeConditionalFlow() -> some Flow {
        return BasicFlow(
            name: "conditional_flow",
            platforms: [.macOS(version: .any)],
            description: "A flow with conditional actions"
        ) { context, _ in
            EchoAction(hint: "Start conditional flow", contentProvider: { .raw(arg: "Starting conditional flow") })
            
            if let value: String = context.get(for: "shouldListFiles"), value == "true" {
                ShellAction(
                    hint: "List directory contents",
                    command: "ls",
                    arguments: [.raw(arg: "-la")],
                    captureOutputToKey: "listing",
                    outputToConsole: true
                )
                EchoAction(hint: "Display directory listing", contentProvider: { .key(key: "listing") })
            } else {
                EchoAction(hint: "Skip file listing", contentProvider: { .raw(arg: "Skipping file listing") })
            }
            
            EchoAction(hint: "Complete flow", contentProvider: { .raw(arg: "Flow completed") })
        }
    }
    
    public static func makeBatchFlow() -> some Flow {
        return BasicFlow(
            name: "batch_flow",
            platforms: [.macOS(version: .any)],
            description: "A flow that executes a batch of commands"
        ) { _, _ in
            EchoAction(hint: "Start batch flow", contentProvider: { .raw(arg: "Starting batch flow") })
            
            // Use fixed test commands instead of parameter
            let commands = ["echo Hello", "echo World", "ls -la"]
            
            for (index, command) in commands.enumerated() {
                ShellAction(hint: "Execute command \(index + 1)", command: command, outputToConsole: true)
            }
            
            EchoAction(hint: "Complete batch flow", contentProvider: { .raw(arg: "Batch flow completed") })
        }
    }
    
    public static func makeComplexFlow() -> some Flow {
        return BasicFlow(
            name: "complex_flow",
            platforms: [.macOS(version: .any), .iOS(version: .any)],
            description: "A complex flow demonstrating various function builder features"
        ) { _, _ in
            // Simple actions
            EchoAction(hint: "Start complex flow", contentProvider: { .raw(arg: "Starting complex flow") })
            
            // Conditional actions based on platform
            #if os(macOS)
            ShellAction(hint: "Get system information", command: "uname", arguments: [.raw(arg: "-a")], captureOutputToKey: "system_info", outputToConsole: true)
            EchoAction(hint: "Display system information", contentProvider: { .key(key: "system_info") })
            #endif
            
            // Multiple actions in sequence
            ShellAction(hint: "Get current directory", command: "pwd", captureOutputToKey: "current_dir", outputToConsole: true)
            EchoAction(hint: "Display current directory", contentProvider: { .key(key: "current_dir") })
            
            // Conditional actions
            if true {  // This could be a runtime condition
                EchoAction(hint: "Condition is true", contentProvider: { .raw(arg: "Condition is true") })
            }
            
            // Array of actions
            for i in 1...3 {
                EchoAction(hint: "Iteration \(i)", contentProvider: { .raw(arg: "Iteration \(i)") })
            }
            
            EchoAction(hint: "Complete complex flow", contentProvider: { .raw(arg: "Complex flow completed") })
        }
    }
    
    public static func makeNestedConditionsFlow() -> some Flow {
        return BasicFlow(
            name: "nested_conditions_flow",
            platforms: [.macOS(version: .any)],
            description: "A flow with nested conditional actions"
        ) { _, _ in
            EchoAction(hint: "Start nested conditions flow", contentProvider: { .raw(arg: "Starting nested conditions flow") })
            
            #if os(macOS)
            if true {
                ShellAction(hint: "Echo on macOS", command: "echo", arguments: [.raw(arg: "On macOS and condition is true")], outputToConsole: true)
                
                for i in 1...2 {
                    if i == 1 {
                        EchoAction(hint: "First iteration", contentProvider: { .raw(arg: "First iteration") })
                    } else {
                        EchoAction(hint: "Second iteration", contentProvider: { .raw(arg: "Second iteration") })
                    }
                }
            }
            #endif
            
            EchoAction(hint: "Complete nested conditions flow", contentProvider: { .raw(arg: "Nested conditions flow completed") })
        }
    }
}
