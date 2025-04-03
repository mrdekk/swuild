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
final class <your name of flow>FlowBuilder: FlowBuilder {
    override func build() -> any Flow {
        <your name of flow>Flow()
    }
}

@_cdecl("makeFlow")
public func makeFlow() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(<your name of flow>FlowBuilder()).toOpaque()
}
```

You could extend this code to provide some more instantiation things (plugin system will load the dylib and call to makeFlow function). Or if you don't want to wrangle around, you could simplify your efforts and use predefined swift macro

```swift
#flowBuildable(<your name of flow>Flow)
```

and system will codegen needed thigs automagically.
