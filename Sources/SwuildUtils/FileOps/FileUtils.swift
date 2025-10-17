//  Created by Denis Malykh on 16.10.2025.

import Foundation

public class FileUtils {
    public static func recursiveCopy(
        from sourcePattern: String,
        to destinationDir: URL,
        outputToConsole: Bool = false,
        fileManager: FileManager = .default
    ) throws {
        let (basePath, filePattern) = try parsePattern(sourcePattern)

        var isDirectory: ObjCBool = false
        let basePathExists = fileManager.fileExists(atPath: basePath, isDirectory: &isDirectory)

        if !basePathExists {
            if outputToConsole {
                print("Warning: Source path \(basePath) does not exist. Copy operation will be skipped.")
                print("Copy finished. 0 files copied.")
            }
            throw FileUtilsError.basePathNotFound(basePath: basePath)
        }

        if !fileManager.fileExists(atPath: destinationDir.path) {
            try createDestinationDirectory(
                url: destinationDir,
                outputToConsole: outputToConsole,
                fileManager: fileManager
            )
        }

        // If basePath is a file, copy it directly
        if !isDirectory.boolValue {
            let sourceURL = URL(fileURLWithPath: basePath)
            let fileName = sourceURL.lastPathComponent
            let destinationURL = destinationDir.appendingPathComponent(fileName)

            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            if outputToConsole {
                print("Copied: \(fileName)")
                print("Copy finished. 1 files copied.")
            }
            return
        }

        // Otherwise, treat as directory with pattern matching
        let baseURL = URL(fileURLWithPath: basePath, isDirectory: true)

        guard let enumerator = fileManager.enumerator(
            at: baseURL,
            includingPropertiesForKeys: [.isDirectoryKey, .nameKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            throw FileUtilsError.directoryEnumeratorFailed
        }

        var copiedCount = 0

        for case let iterFileURL as URL in enumerator {
            let fileURL = if iterFileURL.path.hasPrefix("/private") {
                URL(fileURLWithPath: "\(iterFileURL.path.dropFirst("/private".count))")
            } else {
                iterFileURL
            }
            let resourceValues = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
            let isDirectory = resourceValues.isDirectory ?? false

            if !isDirectory {
                if matchesPattern(fileURL, baseURL: baseURL, pattern: filePattern) {
                    let fileURLPath = fileURL.path
                    let baseURLPath = baseURL.path
                    let relativePath: String = if fileURLPath.hasPrefix(baseURLPath) {
                        String(fileURLPath.dropFirst(baseURLPath.count))
                    } else {
                        fileURLPath
                    }
                    let normalizedRelativePath = relativePath.hasPrefix("/") ? String(relativePath.dropFirst()) : relativePath
                    let destinationURL = destinationDir.appendingPathComponent(normalizedRelativePath)

                    let destinationFolder = destinationURL.deletingLastPathComponent()
                    if !fileManager.fileExists(atPath: destinationFolder.path) {
                        try createDestinationDirectory(
                            url: destinationFolder,
                            outputToConsole: outputToConsole,
                            fileManager: fileManager
                        )
                    }

                    if fileManager.fileExists(atPath: destinationURL.path) {
                        try fileManager.removeItem(at: destinationURL)
                    }
                    try fileManager.copyItem(at: fileURL, to: destinationURL)

                    copiedCount += 1
                    if outputToConsole {
                        print("Copied: \(normalizedRelativePath)")
                    }
                } else {
                    if outputToConsole {
                        print("File \(fileURL.path) does not match pattern \(filePattern)")
                    }
                }
            }
        }

        print("Copy finished. \(copiedCount) files copied.")
    }

    public static func recursiveRemove(
        pattern: String,
        outputToConsole: Bool = false,
        fileManager: FileManager = .default
    ) throws {
        let (basePath, filePattern) = try parsePattern(pattern)

        var isDirectory: ObjCBool = false
        let basePathExists = fileManager.fileExists(atPath: basePath, isDirectory: &isDirectory)

        if !basePathExists {
            if outputToConsole {
                print("Warning: Source path \(basePath) does not exist. Remove operation will be skipped.")
                print("Remove finished. 0 files removed.")
            }
            throw FileUtilsError.basePathNotFound(basePath: basePath)
        }

        // If basePath is a full pattern, just remove it
        if basePath == pattern {
            let sourceURL = URL(fileURLWithPath: basePath)
            do {
                try fileManager.removeItem(at: sourceURL)
                if outputToConsole {
                    print("Removed: \(sourceURL.lastPathComponent)")
                    print("Remove finished. 1 files removed.")
                }
            } catch {
                throw FileUtilsError.removalFailed(path: sourceURL.path, error: error)
            }
            return
        }

        // Otherwise, treat as directory with pattern matching
        let baseURL = URL(fileURLWithPath: basePath, isDirectory: true)

        guard let enumerator = fileManager.enumerator(
            at: baseURL,
            includingPropertiesForKeys: [.isDirectoryKey, .nameKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            throw FileUtilsError.directoryEnumeratorFailed
        }

        var removedCount = 0

        // Collect files to remove first (to avoid modifying collection during enumeration)
        var filesToRemove: [URL] = []

        for case let iterFileURL as URL in enumerator {
            let fileURL = if iterFileURL.path.hasPrefix("/private") {
                URL(fileURLWithPath: "\(iterFileURL.path.dropFirst("/private".count))")
            } else {
                iterFileURL
            }
            let resourceValues = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
            let isDirectory = resourceValues.isDirectory ?? false

            if !isDirectory {
                if matchesPattern(fileURL, baseURL: baseURL, pattern: filePattern) {
                    filesToRemove.append(fileURL)
                } else {
                    if outputToConsole {
                        print("File \(fileURL.path) does not match pattern \(filePattern)")
                    }
                }
            }
        }

        for fileURL in filesToRemove {
            do {
                try fileManager.removeItem(at: fileURL)
                removedCount += 1
                if outputToConsole {
                    let fileURLPath = fileURL.path
                    let baseURLPath = baseURL.path
                    let relativePath: String = if fileURLPath.hasPrefix(baseURLPath) {
                        String(fileURLPath.dropFirst(baseURLPath.count))
                    } else {
                        fileURLPath
                    }
                    let normalizedRelativePath = relativePath.hasPrefix("/") ? String(relativePath.dropFirst()) : relativePath
                    print("Removed: \(normalizedRelativePath)")
                }
            } catch {
                throw FileUtilsError.removalFailed(path: fileURL.path, error: error)
            }
        }

        print("Remove finished. \(removedCount) files removed.")
    }

    private static func createDestinationDirectory(url: URL, outputToConsole: Bool, fileManager: FileManager) throws {
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            if outputToConsole {
                print("Warning: Failed to create destination directory \(url.path): \(error)")
            }
            throw FileUtilsError.directoryCreationFailed(path: url.path)
        }
    }

    private static func parsePattern(_ pattern: String) throws -> (basePath: String, filePattern: String) {
        let components = pattern.components(separatedBy: "/")

        // if there are no wildcards, use whole pattern as base path
        guard let firstWildcardIndex = components.firstIndex(where: { $0.contains("*") }) else {
            return (pattern, "*")
        }

        let baseComponents = Array(components[0..<firstWildcardIndex])
        let basePath = baseComponents.joined(separator: "/")

        let patternComponents = Array(components[firstWildcardIndex...])
        let filePattern = patternComponents.joined(separator: "/")

        guard !basePath.isEmpty else {
            throw FileUtilsError.invalidPattern(message: "Can't autodetect base path from pattern: \(pattern)")
        }

        return (basePath, filePattern)
    }

    private static func matchesPattern(_ fileURL: URL, baseURL: URL, pattern: String) -> Bool {
        let fileURLPath = fileURL.path
        let baseURLPath = baseURL.path

        let relativePath: String = if fileURLPath.hasPrefix(baseURLPath) {
            String(fileURLPath.dropFirst(baseURLPath.count))
        } else {
            fileURLPath
        }
        let normalizedRelativePath = relativePath.hasPrefix("/") ? String(relativePath.dropFirst()) : relativePath
        let regexPattern = convertWildcardPatternToRegex(pattern)
        return normalizedRelativePath.range(of: regexPattern, options: .regularExpression) != nil
    }

    private static func convertWildcardPatternToRegex(_ pattern: String) -> String {
        var regex = "^"

        var idx = pattern.startIndex
        while idx < pattern.endIndex {
            let character = pattern[idx]
            switch character {
            case "*":
                let nextIdx = pattern.index(after: idx)
                if nextIdx < pattern.endIndex, pattern[nextIdx] == "*" {
                    regex += ".*"
                    idx = nextIdx
                } else {
                    regex += "[^/]*"
                }
            case "?":
                regex += "[^/]"
            case ".", "+", "(", ")", "[", "]", "{", "}", "^", "$", "|", "\\":
                regex += "\\" + String(character)
            default:
                regex += String(character)
            }

            idx = pattern.index(after: idx)
        }

        regex += "$"
        return regex
    }

}
