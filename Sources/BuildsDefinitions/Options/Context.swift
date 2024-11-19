//  Created by Denis Malykh on 19.11.2024.

import Foundation

public protocol Option {}

public class OptionValue<T>: Option {
    public var value: T

    public init(defaultValue: T) {
        self.value = defaultValue
    }
}

public class StringOption: OptionValue<String> {}
public class IntOption: OptionValue<Int> {}

public class Context {
    private var storage: [String: Option] = [:]

    public func put<T>(for key: String, option: OptionValue<T>) {
        storage[key] = option
    }

    public func get<T>(for key: String) -> T? {
        guard let known = storage[key] as? OptionValue<T> else {
            return nil
        }

        return known.value
    }

    public func drop(_ key: String) -> Bool {
        let contains = storage[key] != nil
        storage.removeValue(forKey: key)
        return contains
    }

    public static func `default`() -> Context {
        return Context()
    }
}
