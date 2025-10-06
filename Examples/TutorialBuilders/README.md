# TutorialBuilders Example

This example demonstrates how to use the FlowBuilder with function builder syntax in Swuild.

## Overview

The FlowBuilder feature allows you to create flows using a declarative syntax similar to SwiftUI's ViewBuilder. This makes it easier to define complex flows with conditional logic, loops, and other control structures.

## Key Features

1. **Function Builder Syntax**: Use `@FlowActionsBuilder` to create flows with a declarative syntax
2. **Conditional Actions**: Use `if` statements to conditionally include actions in your flow
3. **Looping Actions**: Use `for` loops to generate multiple actions
4. **Platform-Specific Actions**: Use compilation conditions (`#if os(macOS)`) to include platform-specific actions

## Example Usage

The `FlowBuilderExamples` enum contains several examples of how to use the function builder syntax:

- `makeExample()`: A basic flow example
- `makeSimpleFlow()`: A simple flow example
- `makeConditionalFlow(shouldListFiles:)`: A flow with conditional actions
- `makeBatchFlow(commands:)`: A flow that executes a batch of commands
- `makeComplexFlow()`: A complex flow demonstrating various function builder features
- `makeNestedConditionsFlow()`: A flow with nested conditional actions

## Building the Example

To build this example, run:

```bash
swift build
```

## Using the FlowBuildableWithFactory Macro

This example also demonstrates how to use the `#flowBuildableWithFactory` macro to automatically generate a flow builder for your flows:

```swift
#flowBuildableWithFactory(FlowBuilderExamples.self, "makeComplexFlow")
```

This macro generates the necessary code to make your flow loadable by the Swuild system.