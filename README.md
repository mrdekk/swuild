# Swuild

[![Build Swuild](https://github.com/mrdekk/swuild/actions/workflows/build.yaml/badge.svg?branch=main)](https://github.com/mrdekk/swuild/actions/workflows/build.yaml)

Swift build system (aka CI scripts with Swift language)

In early development, no promises yet...

But if you interested in, star the project or fire issues with your willings. Or may be you could make some PR's to extend the functionality. I will be very grateful.

## Basic Usage

With Swuild you can write some CI workflows with swift programming language and pack it to the swift package. Just is.

Basic sample Located in /Sources/Tutorial directory and will be kept up to date.

There are two main things in Swuild: Actions and Flows.

- **Actions**: some parts of work to do (build one item or just report)
- **Flows**: composite of sequential actions to perform some finished work.

For all definitions you have to use 'BuildsDefinitions' package. And for some predefined actions and flows, there are SwuildCore (very basic stuff) and other packages.

You can define your actions as:

```swift
public struct <your name of action>Action: Action {

    // MARK: - BuildsDefinitions.Action

    public static let name = "<some descriptive name>"

    public static let description = "<some human readable description of your action>"

    public static let authors = ["<emails of authors of action>", ...]

    public static func isSupported(for platform: Platform) -> Bool {
        <predicate to check is this action is supported to this platform>
    }

    public func execute(context: Context) async throws -> Result<Void, Error> {
        <your execution code of your action>
    }
}
```

and you can define your flow as:

```swift
public struct <your name of flow>Flow: Flow {
    public let name = "<some descriptive name>"

    public let platforms: [Platform] = [<list of platform that will be used to execute actions>]
    // NOTE: flow will be executed once for each platform

    public let description = "<some human readable description of your flow>"

    public let actions: [any Action] = [
        <instantiate any actions your want to incorporate to this flow>
    ]
}
```  

One final step, to system to be able to compiled, load and execute your flow, you should provide some boilerplate code (sorry for that). In general it looks like:

```swift
@_cdecl("makeFlow")
public func makeFlow() -> UnsafeMutableRawPointer {
    flow { <your name of flow>Flow() }
}
```

"makeFlow" is the function name you could provide as parameter to swuild, and in one module you can have many of them (see TutorialBuilders for example). Swuild will use name of function provided in @_cdecl annotation.

## Function Builder Support

Swuild also supports a SwiftUI-like function builder syntax for defining flows, making it easier to create complex flows with conditional logic and loops. This approach is similar to how SwiftUI uses ViewBuilder for the body property.

To use the function builder approach, you can create flows using the `BasicFlow` struct:

```swift
import BuildsDefinitions
import SwuildCore

let flow = BasicFlow(
    name: "example_flow",
    platforms: [.macOS(version: .any)],
    description: "An example flow using function builder"
) {
    EchoAction { .raw(arg: "Hello from function builder!") }
    ShellAction(command: "echo", arguments: [.raw(arg: "Simple command")])
    
    // Conditional actions
    if shouldListFiles {
        ShellAction(
            command: "ls",
            arguments: [.raw(arg: "-la")],
            captureOutputToKey: "listing"
        )
        EchoAction { .key(key: "listing") }
    }
    
    // Loop actions
    for i in 1...3 {
        EchoAction { .raw(arg: "Iteration \(i)") }
    }
}
```

The function builder supports all standard Swift language features:
1. **Conditional actions** using `if` statements
2. **Array of actions** using `for` loops
3. **Platform-specific actions** using compilation conditions (`#if`)
4. **Combining multiple actions** in a single block

For flows created with the function builder approach, you should write 'makeFlow' function like this:

```swift
@_cdecl("makeBatchFlow")
public func makeBatchFlow() -> UnsafeMutableRawPointer {
    flow { <your flow factory function name>() }
}
```

## Examples

For more detailed examples of how to use Swuild, check out the examples in the `Examples` directory:

1. `Examples/StandardApp` - A complete example of building a standard iOS/macOS app
1. `Examples/Tutorial` - Examples of basic usage of flows and actions
1. `Examples/TutorialBuilders` - Examples of using the function builder syntax for flows

Each example contains its own README.md with detailed instructions on how to build and run it.
