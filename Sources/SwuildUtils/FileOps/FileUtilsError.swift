//  Created by Denis Malykh on 17.10.2025.

import Foundation

public enum FileUtilsError: Error {
    case basePathNotFound(basePath: String)
    case directoryCreationFailed(path: String)
    case directoryEnumeratorFailed
    case invalidPattern(message: String)
    case removalFailed(path: String, error: Error)
}

extension FileUtilsError: Equatable {
    public static func == (lhs: FileUtilsError, rhs: FileUtilsError) -> Bool {
        switch (lhs, rhs) {
        case (.basePathNotFound(let lhsPath), .basePathNotFound(let rhsPath)):
            return lhsPath == rhsPath
        case (.directoryCreationFailed(let lhsPath), .directoryCreationFailed(let rhsPath)):
            return lhsPath == rhsPath
        case (.directoryEnumeratorFailed, .directoryEnumeratorFailed):
            return true
        case (.invalidPattern(let lhsMessage), .invalidPattern(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.removalFailed(let lhsPath, _), .removalFailed(let rhsPath, _)):
            return lhsPath == rhsPath
        default:
            return false
        }
    }
}
