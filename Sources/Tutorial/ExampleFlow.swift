//  Created by Denis Malykh on 20.11.2024.

import BuildsDefinitions
import Foundation
import FlowBuildableSwiftMacro

public struct ExampleFlow: Flow {
    public let name = "example_flow"

    public let platforms: [Platform] = [.iOS(version: .any)]

    public let description = "Just an example flow"

    public let actions: [any Action] = [
        ExampleAction(greeting: "World"),
    ]
}

#flowBuildable(ExampleFlow)
