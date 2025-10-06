//  Created by Denis Malykh on 20.11.2024.

import Foundation

open class FlowBuilder {

    public init() {}

    open func build() -> Flow {
        fatalError("You have to override this method.")
    }
}

// MARK: - Function Builder for Flow Actions

@resultBuilder
public struct FlowActionsBuilder {
    public static func buildBlock(_ components: [any Action]...) -> [any Action] {
        return components.flatMap { $0 }
    }

    public static func buildBlock() -> [any Action] {
        return []
    }

    public static func buildOptional(_ component: [any Action]?) -> [any Action] {
        return component ?? []
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
