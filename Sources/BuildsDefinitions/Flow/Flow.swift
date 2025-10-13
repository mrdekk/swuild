//  Created by Denis Malykh on 19.11.2024.

import Foundation

public enum FlowErrors: Error {
    case actionExecution(cause: Error)
}

public protocol Flow: ContextExecutable {
    var name: String { get }
    var platforms: [Platform] { get }
    var description: String { get }

    func actions(for context: Context, and platform: Platform) -> [any Action]
}

public extension Flow {
    func execute(context: Context, platform: Platform) async throws {
        let actions = actions(for: context, and: platform)
        for action in actions {
            guard type(of: action).isSupported(for: platform) else {
                continue
            }

            try await action.execute(context: context, platform: platform)
        }
    }

    func execute(context: Context) async throws {
        for platform in platforms {
            try await execute(context: context, platform: platform)
        }
    }
}
