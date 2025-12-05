//  Created by Denis Malykh on 05.12.2025.

import Foundation
import Testing

@testable import SwuildCore
@testable import BuildsDefinitions

class MockContext: Context {
    var arguments: [String: Any] = [:]

    func put<T>(for key: String, option: OptionValue<T>) {
        arguments[key] = option.value
    }

    func get<T>(for key: String) -> T? {
        return arguments[key] as? T
    }

    func drop(_ key: String) -> Bool {
        let contains = arguments[key] != nil
        arguments.removeValue(forKey: key)
        return contains
    }

    func setArgument<T>(_ key: String, value: T) {
        arguments[key] = value
    }

    func getArgument(_ key: String) -> String? {
        return arguments[key] as? String
    }

    func option(for key: String) -> Option? {
        return nil
    }
}