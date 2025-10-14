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
    
    public func actions(for context: Context, and platform: Platform) -> [any Action] {
        return [
            EchoAction(hint: "Print welcome message", contentProvider: { .raw(arg: "Just and Echo") }),
            ShellAction(hint: "List directory contents", command: "ls", arguments: [.raw(arg: "-la")], captureOutputToKey: "listing"),
            EchoAction(hint: "Display directory listing", contentProvider: { .key(key: "listing") }),
            ExampleAction(hint: "Run example action", greeting: "World"),
            EchoAction(hint: "Display modified listing", contentProvider: { .modified(key: "listing", modifier: { _, value in value + "AAAA" }) }),

            ConditionalAction(
                predicate: { context, platform in
                    return if let value: String = context.get(for: "shouldRunConditional"), value == "true" {
                        true
                    } else {
                        false
                    }
                },
                action: EchoAction(hint: "Execute when condition is true", contentProvider: { .raw(arg: "Conditional action executed") }),
                elseAction: EchoAction(hint: "Execute when condition is false", contentProvider: { .raw(arg: "Conditional action skipped") })
            ),

            CompositeAction { context, platform in
                EchoAction(hint: "First action in composite", contentProvider: { .raw(arg: "First action in composite") })
                ShellAction(hint: "Second action in composite", command: "echo", arguments: [.raw(arg: "Second action in composite")])
                EchoAction(hint: "Third action in composite", contentProvider: { .raw(arg: "Third action in composite") })
            },

            CallFlowAction(flow: BasicFlow(
                name: "nested_flow_example",
                platforms: [.macOS(version: .any)],
                description: "A simple flow called from CallFlowAction"
            ) { context, platform in
                EchoAction(hint: "Message from nested flow", contentProvider: { .raw(arg: "This is a flow called from CallFlowAction") })
                ShellAction(hint: "Hello from nested flow", command: "echo", arguments: [.raw(arg: "Hello from nested flow")])
            }),
        ]
    }
}

@_cdecl("makeFlow")
public func makeFlow() -> UnsafeMutableRawPointer {
    flow { ExampleFlow() }
}
