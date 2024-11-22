//  Created by Denis Malykh on 22.11.2024.

import Foundation
import SwuildUtils

protocol PackageBuilding {
    func buildPackage(at path: String, productName: String) async throws -> String
}

enum PackageBuilderErrors: Error {
    case noSuchProductDefinition
    case binaryProductMissing
}

final class PackageBuilder: PackageBuilding {

    private let packageLoader: PackageLoading

    init(packageLoader: PackageLoading = PackageLoader()) {
        self.packageLoader = packageLoader
    }

    func buildPackage(at path: String, productName: String) async throws -> String {
        let dump = try packageLoader.loadPackageDump(from: path)
        guard dump.products.contains(where: { $0.name == productName }) else {
            throw PackageBuilderErrors.noSuchProductDefinition
        }

        let binPath = try sh(
            command: "swift", "build", "--product", productName, "--configuration", "release", "--show-bin-path",
            captureOutput: true,
            currentDirectoryPath: path
        ).standardOutput

        try sh(
            command: "swift", "build", "--product", productName, "--configuration", "release",
            currentDirectoryPath: path
        )

        let rs = try FileManager.default.contentsOfDirectory(atPath: binPath)
            .filter { $0.hasSuffix(".dylib") && $0.contains(productName) }

        guard let binName = rs.first else {
            throw PackageBuilderErrors.binaryProductMissing
        }

        return [binPath, binName].joined(separator: "/")
    }
}
