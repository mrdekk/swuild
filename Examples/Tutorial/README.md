# Tutorial Example

This example demonstrates the basic usage of Swuild to create actions and flows.

## Overview

The Tutorial example shows how to:

1. Create custom actions that perform specific tasks
2. Create flows that compose actions into workflows
3. Use the `#flowBuildable` macro for automatic flow loading

## Example Components

### ExampleAction

A simple action that demonstrates the basic structure of a Swuild action. It shows how to:

- Define action metadata (name, description, authors)
- Implement platform support checks
- Write the execution logic

### ExampleFlow

A simple flow that demonstrates how to:

- Define flow metadata (name, description, supported platforms)
- Compose actions into a sequential workflow
- Use the `#flowBuildable` macro for automatic flow loading

## Building the Example

To build this example, run:

```bash
swift build
```

