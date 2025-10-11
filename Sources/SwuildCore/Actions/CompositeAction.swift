//  Created by Denis Malykh on 11.10.2025.

import Foundation
import BuildsDefinitions

public struct CompositeAction: Action {
    public static let name = "composite"
    public static let description = "Executes a series of actions in sequence"
    public static let authors = Author.defaultAuthors
    
    private let _actions: [any Action]

    public init(actions: [any Action]) {
        self._actions = actions
    }

    public init(@FlowActionsBuilder actions: () -> [any Action]) {
        self._actions = actions()
    }

    public static func isSupported(for platform: Platform) -> Bool {
        true
    }
    
    public func execute(context: Context) async throws -> Result<Void, Error> {
        for action in _actions {
            let result = try await action.execute(context: context)
            switch result {
            case .success:
                continue
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(())
    }
}
