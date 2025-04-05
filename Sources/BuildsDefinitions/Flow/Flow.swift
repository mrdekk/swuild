//  Created by Denis Malykh on 19.11.2024.

import Foundation

public enum FlowErrors: Error {
    case actionExecution(cause: Error)
}

public protocol Flow: ContextExecutable {
    var name: String { get }
    var platforms: [Platform] { get }
    var description: String { get }
    var actions: [any Action] { get }
}

public extension Flow {
    func execute(context: Context) async throws -> Result<Void, Error> {
        do {
            for platform in platforms {
                for action in actions {
                    guard type(of: action).isSupported(for: platform) else {
                        continue
                    }

                    let result = try await action.execute(context: context)
                    switch result {
                    case .success:
                        break
                    case let .failure(error):
                        throw FlowErrors.actionExecution(cause: error)
                    }
                }
            }
            return .success(())
        } catch {
            return .failure(FlowErrors.actionExecution(cause: error))
        }
    }
}
