//  Created by Denis Malykh on 20.11.2024.

import Foundation
import BuildsDefinitions

protocol ContextPrintable {
    func printContext()
}

final class ContextImpl: Context, ContextPrintable {
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

    public func option(for key: String) -> Option? {
        return storage[key]
    }

    public func printContext() {
        print("Context is:")
        for (key, option) in storage {
            if let describing = option as? CustomDebugStringConvertible {
                print("  \(key) => \(describing.debugDescription)")
            } else {
                print("  \(key) => <unpresentable>")
            }
        }
    }
}

public func makeContext() -> Context {
    return ContextImpl()
}

