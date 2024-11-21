//  Created by Denis Malykh on 20.11.2024.

import Foundation
import BuildsDefinitions

final class ContextImpl: Context {
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
}


public func makeContext() -> Context {
    return ContextImpl()
}

