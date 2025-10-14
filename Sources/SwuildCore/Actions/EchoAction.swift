//  Created by Denis Malykh on 19.11.2024.

import Foundation
import BuildsDefinitions

public struct EchoAction: Action {

    public typealias ContentProvider = () -> Argument<String>

    public static let name = "echo"
    public static let description = "Simple echo action for tests"
    public static let authors = Author.defaultAuthors

    public static func isSupported(for platform: Platform) -> Bool {
        true
    }

    public let hint: String

    private let contentProvider: ContentProvider

    public init(hint: String = "-", contentProvider: @escaping ContentProvider) {
        self.hint = hint
        self.contentProvider = contentProvider
    }

    public init(hint: String = "-", content: String) {
        self.init(hint: hint, contentProvider: { .raw(arg: content) })
    }

    public func execute(context: Context, platform: Platform) async throws {
        switch contentProvider() {
        case let .raw(message):
            print(message)

        case let .key(key):
            if let value: String = context.get(for: key) {
                print(value)
            } else {
                print("<missing:\(key)>")
            }

        case let .modified(key, modifier):
            if let value: String = context.get(for: key) {
                let modified = try modifier(context, value)
                print("unmodified: \(value), modified: \(modified)")
            } else {
                print("<missing:\(key):modified>")
            }
        }
    }
}
