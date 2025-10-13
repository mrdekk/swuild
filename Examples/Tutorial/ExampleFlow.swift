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
            EchoAction { .raw(arg: "Just and Echo") },
            ShellAction(command: "ls", arguments: [.raw(arg: "-la")], captureOutputToKey: "listing"),
            EchoAction { .key(key: "listing") },
            ExampleAction(greeting: "World"),
            EchoAction { .modified(key: "listing", modifier: { _, value in value + "AAAA" }) },

            if let value: String = context.get(for: "shouldRunConditional"), value == "true" {
                EchoAction { .raw(arg: "Conditional action executed") }
            } else {
                EchoAction { .raw(arg: "Conditional action skipped") }
            },

            CompositeAction {
                EchoAction { .raw(arg: "First action in composite") },
                ShellAction(command: "echo", arguments: [.raw(arg: "Second action in composite")]),
                EchoAction { .raw(arg: "Third action in composite") }
            },

            CallFlowAction(flow: BasicFlow(
                name: "nested_flow_example",
                platforms: [.macOS(version: .any)],
                description: "A simple flow called from CallFlowAction"
            ) { context, platform in
                [
                    EchoAction { .raw(arg: "This is a flow called from CallFlowAction") },
                    ShellAction(command: "echo", arguments: [.raw(arg: "Hello from nested flow")])
                ]
            }),
        ]
    }
}

@_cdecl("makeFlow")
public func makeFlow() -> UnsafeMutableRawPointer {
    flow { ExampleFlow() }
}
