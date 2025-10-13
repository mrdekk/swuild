//  Created by Denis Malykh on 20.11.2024.

import Foundation

public final class FlowBuilder {
    public typealias Buildable = () -> Flow

    private let buildable: Buildable

    public init(buildable: @escaping Buildable) {
        self.buildable = buildable
    }

    public init(flow: Flow) {
        self.buildable = { flow }
    }

    public func build() -> Flow {
        buildable()
    }
}

public func flow(_ buildable: @escaping () -> Flow) -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(
        FlowBuilder(buildable: buildable)
    ).toOpaque()

}

// MARK: - Function Builder for Flow Actions

@resultBuilder
public struct FlowActionsBuilder {
    public static func buildBlock(_ components: (Context, Platform) -> [any Action]...) -> (Context, Platform) -> [any Action] {
        return { context, platform in
            components.flatMap { $0(context, platform) }
        }
    }

    public static func buildBlock() -> (Context, Platform) -> [any Action] {
        return { _, _ in [] }
    }

    public static func buildOptional(_ component: ((Context, Platform) -> [any Action])?) -> (Context, Platform) -> [any Action] {
        return { context, platform in
            component?(context, platform) ?? []
        }
    }

    public static func buildEither(first component: @escaping (Context, Platform) -> [any Action]) -> (Context, Platform) -> [any Action] {
        return { context, platform in
            component(context, platform)
        }
    }

    public static func buildEither(second component: @escaping (Context, Platform) -> [any Action]) -> (Context, Platform) -> [any Action] {
        return { context, platform in
            component(context, platform)
        }
    }

    public static func buildArray(_ components: [(Context, Platform) -> [any Action]]) -> (Context, Platform) -> [any Action] {
        return { context, platform in
            components.flatMap { $0(context, platform) }
        }
    }

    public static func buildExpression(_ expression: any Action) -> (Context, Platform) -> [any Action] {
        return { _, _ in [expression] }
    }
}
