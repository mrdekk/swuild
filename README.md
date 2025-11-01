# Swuild

[![Build Swuild](https://github.com/mrdekk/swuild/actions/workflows/build.yaml/badge.svg?branch=main)](https://github.com/mrdekk/swuild/actions/workflows/build.yaml)

Swift build system (aka CI scripts with Swift language)

### Pronunciation

Transcription (IPA): /swɪld/
Approximate Russian pronunciation: свИлд

How it sounds:
- sw — as in words swim, sweet
- ɪ — short vowel sound, as in words bild, sit, milk
- ld — as in words build, child, wold

Example rhyme: This word would rhyme with swift (quickly) and build (to construct).

In early development, no promises yet...

But if you're interested, star the project or file issues with your suggestions. Or maybe you could make some PRs to extend the functionality. I will be very grateful.

## Basic Usage

With Swuild you can write CI workflows with the Swift programming language and package them into a Swift package. That's it.

The basic sample is located in the /Sources/Tutorial directory and will be kept up to date.

There are two main things in Swuild: Actions and Flows.

- **Actions**: some parts of work to do (build one item or just report)
- **Flows**: composite of sequential actions to perform some finished work.

All actions have a `hint` property that provides human-readable information about what the action does when used in a flow. This is particularly useful for debugging and understanding complex flows. When creating actions, it's recommended to provide meaningful hint values that clearly describe what the action does, rather than using the default "-" value.

For example:
```swift
// Instead of using the default hint value
EchoAction { .raw(arg: "Hello World") }

// Use a meaningful hint value
EchoAction(hint: "Print greeting message", contentProvider: { .raw(arg: "Hello World") })
```

For all definitions, you have to use the 'BuildsDefinitions' package. And for some predefined actions and flows, there are SwuildCore (very basic stuff) and other packages.

## Predefined Actions in SwuildCore

SwuildCore provides several predefined actions that you can use in your flows:

1. **EchoAction**: Prints a message to the console. Can use either a raw string or a context key.
2. **ShellAction**: Executes shell commands. Can capture output to a context key.
3. **AdHocAction**: Allows you to define custom actions inline with a closure.
4. **FileAction**: Provides file operations like copying, moving, and deleting.
5. **TarAction**: Creates and extracts tar archives.
6. **ConditionalAction**: Executes an action only if a condition is met, with optional else action.
7. **CallFlowAction**: Executes another flow.
8. **CompositeAction**: Executes a series of actions in sequence.

### FileAction

The `FileAction` provides file operations including copying, moving, and deleting files and directories. One of its key features is the enhanced copy functionality that supports wildcards and recursive copying.

#### Copy Operation

The copy operation in `FileAction` uses a FileManager-based implementation that supports wildcard patterns, making it easy to copy multiple files matching a pattern. The implementation handles recursive copying of directory structures while preserving the directory hierarchy.

Example usage:
```swift
// Copy a single file
FileAction(
    hint: "Copy configuration file",
    job: .copy(from: .raw(arg: "config.plist"), to: .raw(arg: "output/config.plist"))
)

// Copy files matching a wildcard pattern
FileAction(
    hint: "Copy all Swift files",
    job: .copy(from: .raw(arg: "Sources/**/*.swift"), to: .raw(arg: "output/Sources"))
)

// Copy using context keys
FileAction(
    hint: "Copy build artifacts",
    job: .copy(from: .key(key: "buildOutputPath"), to: .key(key: "deploymentPath"))
)
```

The copy operation supports:
- Simple file-to-file copying
- Directory copying with recursive structure preservation
- Wildcard patterns (e.g., `*.txt`, `**/*.swift`) for copying multiple files
- Context key resolution for dynamic paths

When using wildcards, the system automatically detects the base path and copies all files matching the pattern while preserving the directory structure relative to the base path.

### ConditionalAction

The `ConditionalAction` allows you to conditionally execute actions based on a predicate function that takes a `Context` and returns a `Bool`. It also supports an optional `elseAction` that will be executed if the condition is false.

Example usage:
```swift
ConditionalAction(
    predicate: { context, platform in
        // Check if a specific key exists in context
        return context.get(for: "shouldRun") != nil
    },
    action: EchoAction(hint: "Execute when condition is true", contentProvider: { .raw(arg: "Condition is true!") }),
    elseAction: EchoAction(hint: "Execute when condition is false", contentProvider: { .raw(arg: "Condition is false!") })
)
```

### CallFlowAction

The `CallFlowAction` allows you to execute another flow from within an action. This is useful for composing complex workflows from smaller, reusable flows.

Example usage:
```swift
CallFlowAction(flow: BasicFlow(
    name: "nested_flow",
    platforms: [.macOS(version: .any)],
    description: "A nested flow"
) { _, _ in
    EchoAction(hint: "Message from nested flow", contentProvider: { .raw(arg: "This is a nested flow") })
})
```

### CompositeAction

The `CompositeAction` allows you to group multiple actions together and execute them sequentially as a single action. This is useful for organizing related actions or reusing common sequences of actions across different flows.

Example usage:
```swift
CompositeAction { _, _ in
    EchoAction(hint: "First action in composite", contentProvider: { .raw(arg: "First action in composite") }),
    ShellAction(hint: "Second action in composite", command: "echo", arguments: [.raw(arg: "Second action in composite")]),
    EchoAction(hint: "Third action in composite", contentProvider: { .raw(arg: "Third action in composite") })
}
```

You can define your actions as:

```swift
public struct <your name of action>Action: Action {
    public let hint: String

    // MARK: - BuildsDefinitions.Action

    public static let name = "<some descriptive name>"

    public static let description = "<some human readable description of your action>"

    public static let authors = ["<emails of authors of action>", ...]

    public static func isSupported(for platform: Platform) -> Bool {
        <predicate to check if this action is supported on this platform>
    }

    public init(hint: String = "-", <other parameters>) {
        self.hint = hint
        // Initialize other properties
    }

    public func execute(context: Context, platform: Platform) async throws {
        <your action execution code>
    }
}
```

When implementing actions, it's recommended to provide meaningful hint values that clearly describe what the action does. This makes it easier to understand complex flows when they are executed.

and you can define your flow as:

```swift
public struct <your name of flow>Flow: Flow {
    public let name = "<some descriptive name>"

    public let platforms: [Platform] = [<list of platform that will be used to execute actions>]
    // NOTE: flow will be executed once for each platform

    public let description = "<some human readable description of your flow>"

    public func actions(for context: Context, and platform: Platform) -> [any Action] {
        return [
            <instantiate any actions you want to incorporate into this flow>
        ]
    }
}
```  

One final step: for the system to be able to compile, load, and execute your flow, you should provide some boilerplate code (sorry for that). In general, it looks like:

```swift
@_cdecl("makeFlow")
public func makeFlow() -> UnsafeMutableRawPointer {
    flow { <your name of flow>Flow() }
}
```

"makeFlow" is the function name you can provide as a parameter to swuild, and in one module you can have many of them (see TutorialBuilders for example). Swuild will use the name of the function provided in the @_cdecl annotation.

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
) { _, _ in
    EchoAction(hint: "Greeting from function builder", contentProvider: { .raw(arg: "Hello from function builder!") })
    ShellAction(hint: "Execute simple command", command: "echo", arguments: [.raw(arg: "Simple command")])
    
    // Conditional actions
    if let value: String = context.get(for: "shouldListFiles"), value == "true" {
        ShellAction(
            hint: "List directory contents",
            command: "ls",
            arguments: [.raw(arg: "-la")],
            captureOutputToKey: "listing"
        )
        EchoAction(hint: "Display directory listing", contentProvider: { .key(key: "listing") })
    }
    
    // Loop actions
    for i in 1...3 {
        EchoAction(hint: "Iteration \(i)", contentProvider: { .raw(arg: "Iteration \(i)") })
    }
}
```

The function builder supports all standard Swift language features:
1. **Conditional actions** using `if` statements
2. **Array of actions** using `for` loops
3. **Platform-specific actions** using compilation conditions (`#if`)
4. **Combining multiple actions** in a single block

For flows created with the function builder approach, you should write the 'makeFlow' function like this:

```swift
@_cdecl("makeBatchFlow")
public func makeBatchFlow() -> UnsafeMutableRawPointer {
    flow { <your flow factory function>() }
}
```

## Examples

For more detailed examples of how to use Swuild, check out the examples in the `Examples` directory:

1. `Examples/StandardApp` - A complete example of building a standard iOS/macOS app
1. `Examples/Tutorial` - Examples of basic usage of flows and actions
1. `Examples/TutorialBuilders` - Examples of using the function builder syntax for flows

Each example contains its own README.md with detailed instructions on how to build and run it.
