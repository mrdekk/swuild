//  Created by Denis Malykh on 22.11.2024.

import Foundation
import BuildsDefinitions

public struct PackageDump: Codable {
    public let dependencies: [PackageDependency]
    public let name: String
    public let platforms: [Platform]
    public let products: [Product]
    public let targets: [Target]

    public struct PackageDependency: Codable {
        public let scm: [SourceControlManager]?

        public struct SourceControlManager: Codable {
            public let identity: String
            public let location: String
            public let requirement: Requirement

            public struct Requirement: Codable {
                public let range: [VersionRange]?

                public struct VersionRange: Codable {
                    public let lowerBound: String
                    public let upperBound: String
                }
            }
        }
    }

    public struct Platform: Codable {
        // let options: ?
        public let platformName: String
        public let version: String?
    }

    public struct Product: Codable {
        public let name: String
        public let targets: [String]
        public let type: ProductType

        public struct ProductType: Codable {
            public let executable: String?
            public let library: [String]?
        }
    }

    public struct Target: Codable {
        public let dependencies: [Dependency]
        public let name: String
        public let type: TargetType

        public struct Dependency: Codable {
            public let product: [String?]?
            public let byName: [String?]?
        }

        public enum TargetType: String, Codable {
            case regular
            case test
            case macro
            case executable
        }
    }
}

public class PackageDumpOption: OptionValue<PackageDump> {}
