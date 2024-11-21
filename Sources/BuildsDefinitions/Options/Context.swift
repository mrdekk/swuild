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

public protocol Context {
    func put<T>(for key: String, option: OptionValue<T>)
    func get<T>(for key: String) -> T?
    func drop(_ key: String) -> Bool
}
