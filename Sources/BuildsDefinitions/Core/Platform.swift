//  Created by Denis Malykh on 19.11.2024.

import Foundation

public enum Platform {
    public enum iOSVersions {
        // TODO: to be defined somehow, just a valid extension point
        case any
    }

    public enum macOSVersions {
        // TODO: to be defined somehow, just a valid extension point
        case any
    }

    case iOS(version: iOSVersions)
    case macOS(version: macOSVersions)
}

extension Platform: CustomStringConvertible {
    public var description: String {
        switch self {
        case .iOS(let version):
            "iOS, version: \(version.description)"
        case .macOS(let version):
            "macOS, version: \(version.description)"
        }
    }
}

extension Platform.iOSVersions: CustomStringConvertible {
    public var description: String {
        switch self {
        case .any: "any"
        }
    }
}

extension Platform.macOSVersions: CustomStringConvertible {
    public var description: String {
        switch self {
        case .any: "any"
        }
    }
}
