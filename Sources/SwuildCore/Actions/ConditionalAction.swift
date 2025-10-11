//  Created by Denis Malykh on 11.10.2025.

import Foundation
import BuildsDefinitions

public struct ConditionalAction: Action {
    public typealias Predicate = (_ context: Context) -> Bool
    
    public static let name = "conditional"
    public static let description = "Executes an action only if a condition is met, with optional else action"
    public static let authors = Author.defaultAuthors
    
    private let predicate: Predicate
    private let action: any Action
    private let elseAction: (any Action)?
    
    public init(predicate: @escaping Predicate, action: any Action, elseAction: (any Action)? = nil) {
        self.predicate = predicate
        self.action = action
        self.elseAction = elseAction
    }
    
    public static func isSupported(for platform: Platform) -> Bool {
        true
    }
    
    public func execute(context: Context) async throws -> Result<Void, Error> {
        if predicate(context) {
            return try await action.execute(context: context)
        } else if let elseAction = elseAction {
            return try await elseAction.execute(context: context)
        }
        
        return .success(())
    }
}