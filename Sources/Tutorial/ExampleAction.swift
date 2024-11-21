//  Created by Denis Malykh on 20.11.2024.

import Foundation
import BuildsDefinitions

public struct ExampleAction: Action {

    private let greeting: String

    public init(greeting: String) {
        self.greeting = greeting
    }

    // MARK: - BuildsDefinitions.Action

    public static let name = "example"

    public static let description = "Example action for example flow"

    public static let authors = Author.defaultAuthors

    public static func isSupported(for platform: Platform) -> Bool {
        true
    }

    public func execute(context: Context) async throws -> Result<Void, Error> {
        print("Hello, \(greeting)! This is an example action")
        return .success(())
    }
}
