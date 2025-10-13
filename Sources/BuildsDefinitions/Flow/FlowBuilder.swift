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
    public static func buildBlock(_ components: [any Action]...) -> [any Action] {
        components.flatMap { $0 }
    }

    public static func buildBlock() -> [any Action] {
        []
    }

    public static func buildOptional(_ component: [any Action]?) -> [any Action] {
        component ?? []
    }

    public static func buildEither(first component: [any Action]) -> [any Action] {
        return component
    }

    public static func buildEither(second component: [any Action]) -> [any Action] {
        return component
    }

    public static func buildArray(_ components: [[any Action]]) -> [any Action] {
        return components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: any Action) -> [any Action] {
        return [expression]
    }
}
