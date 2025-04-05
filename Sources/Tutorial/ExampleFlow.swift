//  Created by Denis Malykh on 20.11.2024.

import BuildsDefinitions
import Foundation
import FlowBuildableSwiftMacro
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
    ]
}

#flowBuildable(ExampleFlow)
