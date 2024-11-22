//  Created by Denis Malykh on 22.11.2024.

import Foundation
import SwuildUtils

protocol PackageLoading {
    func loadPackageDump(from path: String) throws -> PackageDump
}

final class PackageLoader: PackageLoading {
    func loadPackageDump(from path: String) throws -> PackageDump {
        let result = try sh(
            command: "swift", "package", "dump-package",
            captureOutput: true,
            currentDirectoryPath: path
        )
        let data = Data(result.standardOutput.utf8)
        return try JSONDecoder().decode(PackageDump.self, from: data)
    }
}
