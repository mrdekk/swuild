//  Created by Denis Malykh on 22.11.2024.

import Foundation
import BuildsDefinitions

public struct AdHocAction: Action {

    public typealias AdHocAction = (_ context: Context) async throws -> Result<Void, Error>

    public static let name = "adhoc"
    public static let description = "Adhoc action to plug into flow"
    public static let authors = Author.defaultAuthors

    public static func isSupported(for platform: Platform) -> Bool {
        true
    }

    private let action: AdHocAction

    public init(action: @escaping AdHocAction) {
        self.action = action
    }

    public func execute(context: Context) async throws -> Result<Void, Error> {
        return try await action(context)
    }
}
