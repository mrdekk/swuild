//  Created by Denis Malykh on 19.11.2024.

import Foundation

public enum FlowErrors: Error {
    case actionExecution(cause: Error)
}

public protocol Flow {
    var name: String { get }
    var platforms: [Platform] { get }
    var description: String { get }
    var actions: [any Action] { get }
}
