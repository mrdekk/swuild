//  Created by Denis Malykh on 11.10.2025.

import Foundation
import BuildsDefinitions

public struct ConditionalAction: Action {
    public typealias Predicate = (_ context: Context, _ platform: Platform) -> Bool

    public static let name = "conditional"
    public static let description = "Executes an action only if a condition is met, with optional else action"
    public static let authors = Author.defaultAuthors

    public let hint: String
    public let mutualExclusivityKey: String?

    private let predicate: Predicate
    private let action: any Action
    private let elseAction: (any Action)?
    
    public init(
        hint: String = "-",
        mutualExclusivityKey: String? = nil,
        predicate: @escaping Predicate,
        action: any Action,
        elseAction: (any Action)? = nil
    ) {
        self.hint = hint
        self.mutualExclusivityKey = mutualExclusivityKey
        self.predicate = predicate
        self.action = action
        self.elseAction = elseAction
    }
    
    public static func isSupported(for platform: Platform) -> Bool {
        true
    }
    
    public func execute(context: Context, platform: Platform) async throws {
        guard canExecute(context: context, platform: platform) else {
            return
        }

        if predicate(context, platform) {
            if action.canExecute(context: context, platform: platform) {
                return try await action.execute(context: context, platform: platform)
            }
        } else if let elseAction = elseAction {
            if elseAction.canExecute(context: context, platform: platform) {
                return try await elseAction.execute(context: context, platform: platform)
            }
        }
    }
}
