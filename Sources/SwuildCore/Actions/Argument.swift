//  Created by Denis Malykh on 04.04.2025.

import BuildsDefinitions

public enum Argument<T> {
    case raw(arg: T)
    case key(key: String)
    case modified(key: String, modifier: (_ context: Context, _ value: T) throws -> T)
}

public extension Context {
    func arg<T>(_ argument: Argument<T>) throws -> T? {
        switch argument {
        case let .raw(str):
            return str

        case let .key(key):
            return get(for: key)

        case let .modified(key, modifier):
            return try get(for: key).flatMap {
                try modifier(self, $0)
            }
        }
    }
}

extension Argument: ExpressibleByUnicodeScalarLiteral where T == String {}
extension Argument: ExpressibleByExtendedGraphemeClusterLiteral where T == String {}

extension Argument: ExpressibleByStringLiteral where T == String {
    public init(stringLiteral value: String) {
        self = .raw(arg: value)
    }
}
