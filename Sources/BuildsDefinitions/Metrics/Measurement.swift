//  Created by Denis Malykh on 21.10.2025.

import Foundation

/// Structure to hold measurement data for action execution metrics
public struct Measurement {
    /// Part of context with needed keys (list of keys is passed to some actions)
    public let contextData: [String: Option]
    
    /// Start time of execution in TimeInterval (unix epoch time, i.e. timeIntervalSince1970)
    public let startTime: TimeInterval
    
    /// Monotonic execution time
    public let executionTime: TimeInterval
    
    /// Hint for the measurement
    public let hint: String
    
    public init(
        contextData: [String: Option],
        startTime: TimeInterval,
        executionTime: TimeInterval,
        hint: String
    ) {
        self.contextData = contextData
        self.startTime = startTime
        self.executionTime = executionTime
        self.hint = hint
    }
}

public class MeasurementsOption: OptionValue<[String: Measurement]> {
    public init() {
        super.init(defaultValue: [:])
    }
}
