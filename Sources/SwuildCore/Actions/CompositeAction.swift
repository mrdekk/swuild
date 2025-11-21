//  Created by Denis Malykh on 11.10.2025.

import Foundation
import BuildsDefinitions

public struct CompositeAction: Action {
    public static let name = "composite"
    public static let description = "Executes a series of actions in sequence"
    public static let authors = Author.defaultAuthors

    public let hint: String
    public let mutualExclusivityKey: String?
    public let measurementKeys: [String: String]?

    /// If true, exceptions thrown by child actions will be caught and logged,
    /// but not propagated further. If false, exceptions will be propagated normally.
    public let swallowExceptions: Bool

    private let actionsBuilder: (Context, Platform) -> [any Action]

    public func actions(for context: Context, and platform: Platform) -> [any Action] {
        return actionsBuilder(context, platform)
    }

    public init(
        hint: String = "-",
        mutualExclusivityKey: String? = nil,
        measurementKeys: [String: String]? = nil,
        swallowExceptions: Bool = false,
        @FlowActionsBuilder actions: @escaping (Context, Platform) -> [any Action]
    ) {
        self.hint = hint
        self.mutualExclusivityKey = mutualExclusivityKey
        self.measurementKeys = measurementKeys
        self.swallowExceptions = swallowExceptions
        self.actionsBuilder = actions
    }

    public static func isSupported(for platform: Platform) -> Bool {
        true
    }
    
    public func execute(context: Context, platform: Platform) async throws {
        let startTime = Date().timeIntervalSince1970
        let monotonicStartTime = CFAbsoluteTimeGetCurrent()

        let actions = actions(for: context, and: platform)
        for action in actions {
            guard action.canExecute(context: context, platform: platform) else {
                continue
            }

            if swallowExceptions {
                do {
                    try await action.execute(context: context, platform: platform)
                } catch {
                    print("CompositeAction: Caught exception from child action '\(action.hint)': \(error)")
                }
            } else {
                try await action.execute(context: context, platform: platform)
            }
        }

        let monotonicEndTime = CFAbsoluteTimeGetCurrent()
        let executionTime = monotonicEndTime - monotonicStartTime

        if let keys = measurementKeys {
            context.addMeasurement(
                .init(
                    contextData: context.extractContextData(for: keys),
                    startTime: startTime,
                    executionTime: executionTime,
                    hint: hint
                ),
                withKey: hint
            )
        }
    }
}
