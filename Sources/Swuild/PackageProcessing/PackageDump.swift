//  Created by Denis Malykh on 22.11.2024.

import Foundation

struct PackageDump: Codable {
    let dependencies: [PackageDependency]
    let name: String
    let platforms: [Platform]
    let products: [Product]
    let targets: [Target]

    struct PackageDependency: Codable {
        let scm: [SourceControlManager]?

        struct SourceControlManager: Codable {
            let identity: String
            let location: String
            let requirement: Requirement

            struct Requirement: Codable {
                let range: [VersionRange]?

                struct VersionRange: Codable {
                    let lowerBound: String
                    let upperBound: String
                }
            }
        }
    }

    struct Platform: Codable {
        // let options: ?
        let platformName: String
        let version: String?
    }

    struct Product: Codable {
        let name: String
        let targets: [String]
        let type: ProductType

        struct ProductType: Codable {
            let executable: String?
            let library: [String]?
        }
    }

    struct Target: Codable {
        let dependencies: [Dependency]
        let name: String
        let type: TargetType

        struct Dependency: Codable {
            let product: [String?]?
            let byName: [String?]?
        }

        enum TargetType: String, Codable {
            case regular
            case test
            case macro
            case executable
        }
    }
}
