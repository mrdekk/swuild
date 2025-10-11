//  Created by Denis Malykh on 20.11.2024.

import BuildsDefinitions
import Foundation
import SwuildCore

public struct ExampleFlow: Flow {
    public let name = "example_flow"
    
    public let platforms: [Platform] = [
        .iOS(version: .any),
        .macOS(version: .any),
    ]
    
    public let description = "Just an example flow"
    
    public let actions: [any Action] = [
        EchoAction { .raw(arg: "Just and Echo") },
        ShellAction(command: "ls", arguments: [.raw(arg: "-la")], captureOutputToKey: "listing"),
        EchoAction { .key(key: "listing") },
        ExampleAction(greeting: "World"),

        ConditionalAction(
            predicate: { context in
                // Check if a specific key exists in context with value "true"
                if let value: String = context.get(for: "shouldRunConditional") {
                    return value == "true"
                }
                return false
            },
            action: EchoAction { .raw(arg: "Conditional action executed!") },
            elseAction: EchoAction { .raw(arg: "Conditional action skipped, else action executed!") }
        ),

        CallFlowAction(flow: BasicFlow(
            name: "nested_flow_example",
            platforms: [.macOS(version: .any)],
            description: "A simple flow called from CallFlowAction"
        ) {
            EchoAction { .raw(arg: "This is a flow called from CallFlowAction") }
            ShellAction(command: "echo", arguments: [.raw(arg: "Hello from nested flow")])
        }),
    ]
}

@_cdecl("makeFlow")
public func makeFlow() -> UnsafeMutableRawPointer {
    flow { ExampleFlow() }
}
