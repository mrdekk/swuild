//  Created by Denis Malykh on 05.12.2025.

import Foundation

/// This struct contains all the parameters needed to configure an xcode_select action.
public struct XcodeSelectParams {
    
    /// Path to the Xcode application (e.g. "/Applications/Xcode.app")
    public let xcodePath: String
    
    // MARK: - Initialization
    
    /// Initialize XcodeSelectParams with the required Xcode path
    /// - Parameter xcodePath: Path to the Xcode application
    public init(xcodePath: String) {
        self.xcodePath = xcodePath
    }
}
