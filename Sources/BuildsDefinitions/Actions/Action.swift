//  Created by Denis Malykh on 19.11.2024.

import Foundation

public protocol Action: ContextExecutable {
    /// The name of the action
    static var name: String { get }

    /// A description of what the action does
    static var description: String { get }

    /// The authors of the action
    static var authors: [Author] { get }

    /// Check if the action is supported for a given platform
    /// - Parameter platform: The platform to check support for
    /// - Returns: True if the action is supported for the platform, false otherwise
    static func isSupported(for platform: Platform) -> Bool
    
    /// Execute the action with the given context
    /// - Parameter context: The context in which to execute the action
    /// - Returns: A result indicating success or failure
    func execute(context: Context, platform: Platform) async throws
}
