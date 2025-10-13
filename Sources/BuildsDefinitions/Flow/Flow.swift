//  Created by Denis Malykh on 19.11.2024.

import Foundation

public enum FlowErrors: Error {
    case actionExecution(cause: Error)
}

public protocol Flow: ContextExecutable {
    var name: String { get }
    var platforms: [Platform] { get }
    var description: String { get }

    func actions(for context: Context, and platform: Platform) throws -> [any Action]
}

public extension Flow {
    func execute(context: Context, platform: Platform) async throws {
        let actions = try actions(for: context, and: platform)
        for action in actions {
            print("⚡️ Executing \(type(of: action).name) action...")
            guard type(of: action).isSupported(for: platform) else {
                print("❗️ Action \(type(of: action).name) is not supported for \(platform), skipping!")
                continue
            }

            try await action.execute(context: context, platform: platform)
        }
    }

    func execute(context: Context) async throws {
        print("⚡️ Executing \(name) flow...")
        for platform in platforms {
            print("⚡️ Executing \(name) flow on platform \(platform)...")
            try await execute(context: context, platform: platform)
        }
    }
}
