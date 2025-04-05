//  Created by Denis Malykh on 04.04.2025.

import BuildsDefinitions

public enum Argument<T> {
    case raw(arg: T)
    case key(key: String)
}

public extension Context {
    func arg<T>(_ argument: Argument<T>) -> T? {
        switch argument {
        case let .raw(str):
            return str

        case let .key(key):
            return get(for: key)
        }
    }
}
