//  Created by Denis Malykh on 21.10.2025.

public extension Context {
    /// Extract context data for the specified keys
    func extractContextData(for keys: [String]) -> [String: Option] {
        var contextData: [String: Option] = [:]
        for key in keys {
            if let option = option(for: key) {
                contextData[key] = option
            } else {
                contextData[key] = StringOption(defaultValue: "<missing>")
            }
        }
        return contextData
    }
}
