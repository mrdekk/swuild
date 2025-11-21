//  Created by Denis Malykh on 22.11.2024.

import Foundation
import BuildsDefinitions

public struct AdHocAction: Action {
    public typealias AdHocAction = (_ context: Context, _ platform: Platform) async throws -> Void

    public static let name = "adhoc"
    public static let description = "Adhoc action to plug into flow"
    public static let authors = Author.defaultAuthors

    public static func isSupported(for platform: Platform) -> Bool {
        true
    }

    public let hint: String
    public let mutualExclusivityKey: String?

    private let action: AdHocAction

    public init(hint: String = "-", mutualExclusivityKey: String? = nil, action: @escaping AdHocAction) {
        self.hint = hint
        self.mutualExclusivityKey = mutualExclusivityKey
        self.action = action
    }

    public func execute(context: Context, platform: Platform) async throws {
        try await action(context, platform)
    }
}
