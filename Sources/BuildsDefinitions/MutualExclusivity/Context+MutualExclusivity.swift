//  Created by Assistant on 21.11.2025.

import Foundation

public extension Context {
    var mutualExclusivityKeysKey: String {
        "mutual_exclusivity_keys"
    }
    
    func getExecutedMutualExclusivityKeys() -> Set<String> {
        guard let result: Set<String> = get(for: mutualExclusivityKeysKey) else {
            return Set<String>()
        }
        
        return result
    }
    
    func addExecutedMutualExclusivityKey(_ key: String) {
        var keys = getExecutedMutualExclusivityKeys()
        keys.insert(key)
        
        let keysOption = OptionValue<Set<String>>(defaultValue: keys)
        put(for: mutualExclusivityKeysKey, option: keysOption)
    }
    
    func isMutualExclusivityKeyExecuted(_ key: String) -> Bool {
        return getExecutedMutualExclusivityKeys().contains(key)
    }
}
