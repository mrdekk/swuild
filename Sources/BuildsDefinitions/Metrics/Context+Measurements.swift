//  Created by Denis Malykh on 21.10.2025.
//

import Foundation

public extension Context {
    var measurementsKey: String {
        "measurements"
    }

    /// Get all measurements from context
    func getMeasurements() -> [String: Measurement] {
        guard let result: [String: Measurement] = get(for: measurementsKey) else {
            return [:]
        }

        return result
    }
    
    /// Add a measurement to context
    func addMeasurement(_ measurement: Measurement, withKey key: String) {
        var measurements = getMeasurements()
        measurements[key] = measurement
        
        let measurementsOption = MeasurementsOption()
        measurementsOption.value = measurements
        put(for: measurementsKey, option: measurementsOption)
    }
}
