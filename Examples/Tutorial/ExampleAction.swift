//  Created by Denis Malykh on 20.11.2024.

import Foundation
import BuildsDefinitions

public struct ExampleAction: Action {

    public let hint: String
    private let greeting: String

    public init(hint: String = "-", greeting: String) {
        self.hint = hint
        self.greeting = greeting
    }

    // MARK: - BuildsDefinitions.Action

    public static let name = "example"

    public static let description = "Example action for example flow"

    public static let authors = Author.defaultAuthors

    public static func isSupported(for platform: Platform) -> Bool {
        true
    }

    public func execute(context: Context, platform: Platform) async throws {
        print("Hello, \(greeting)! This is an example action")

        print("Context values:")
        for key in ["test1", "test2", "test3", "customKey"] {
            if let value: String = context.get(for: key) {
                print("  \(key) = \(value)")
            }
        }
    }
}
