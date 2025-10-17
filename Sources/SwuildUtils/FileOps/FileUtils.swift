//  Created by Denis Malykh on 16.10.2025.

import Foundation

/// An enumeration that defines how to handle folder structure preservation when using wildcards in file patterns.
///
/// - first: Preserves folder structure from the first wildcard onwards.
/// - last: Preserves folder structure from the last wildcard onwards.
public enum WildcardMode {
    case first
    case last
}

public class FileUtils {
    /// Recursively copies files matching a pattern from a source directory to a destination directory.
    ///
    /// - Parameters:
    ///   - sourcePattern: The source pattern to match files against. Can include wildcards like `*` and `**`.
    ///   - destinationDir: The destination directory where matched files will be copied.
    ///   - outputToConsole: Whether to output progress information to the console. Defaults to `false`.
    ///   - wildcardMode: Controls how the folder structure is preserved when copying files with wildcards.
    ///     - `.first`: Preserves the folder structure from the first wildcard onwards (default behavior).
    ///     - `.last`: Preserves the folder structure from the last wildcard onwards.
    ///   - fileManager: The FileManager instance to use for file operations. Defaults to `.default`.
    /// - Throws: FileUtilsError if there are issues with file operations.
    public static func recursiveCopy(
        from sourcePattern: String,
        to destinationDir: URL,
        outputToConsole: Bool = false,
        wildcardMode: WildcardMode = .first,
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
                    let normalizedRelativePath = calculateRelativePath(
                        fileURL: fileURL,
                        baseURL: baseURL,
                        filePattern: filePattern,
                        wildcardMode: wildcardMode
                    )
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

        // Collect items to remove first (to avoid modifying collection during enumeration)
        // We need to collect both files and directories that match the pattern
        var itemsToRemove: [URL] = []

        for case let iterFileURL as URL in enumerator {
            let fileURL = if iterFileURL.path.hasPrefix("/private") {
                URL(fileURLWithPath: "\(iterFileURL.path.dropFirst("/private".count))")
            } else {
                iterFileURL
            }
            let resourceValues = try fileURL.resourceValues(forKeys: [.isDirectoryKey])

            if matchesPattern(fileURL, baseURL: baseURL, pattern: filePattern) {
                itemsToRemove.append(fileURL)
            }
        }

        // Sort items to remove directories after files (reverse order of path depth)
        // This ensures we remove files before their parent directories
        itemsToRemove.sort { url1, url2 in
            url1.pathComponents.count > url2.pathComponents.count
        }

        for itemURL in itemsToRemove {
            do {
                try fileManager.removeItem(at: itemURL)
                removedCount += 1
                if outputToConsole {
                    let itemURLPath = itemURL.path
                    let baseURLPath = baseURL.path
                    let relativePath: String = if itemURLPath.hasPrefix(baseURLPath) {
                        String(itemURLPath.dropFirst(baseURLPath.count))
                    } else {
                        itemURLPath
                    }
                    let normalizedRelativePath = relativePath.hasPrefix("/") ? String(relativePath.dropFirst()) : relativePath
                    print("Removed: \(normalizedRelativePath)")
                }
            } catch {
                throw FileUtilsError.removalFailed(path: itemURL.path, error: error)
            }
        }

        print("Remove finished. \(removedCount) items removed.")
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

    /// Calculates the relative path for a file based on the wildcard mode.
    ///
    /// This function determines how to preserve folder structure when copying files with wildcards.
    /// - For `.first` mode: Preserves the folder structure from the first wildcard onwards
    /// - For `.last` mode: Preserves only the folder structure from the last wildcard onwards
    ///
    /// - Parameters:
    ///   - fileURL: The URL of the file being processed.
    ///   - baseURL: The base URL of the source directory.
    ///   - filePattern: The file pattern being used for matching.
    ///   - wildcardMode: The mode that determines how to preserve folder structure.
    /// - Returns: The relative path to use for the destination file.
    private static func calculateRelativePath(
        fileURL: URL,
        baseURL: URL,
        filePattern: String,
        wildcardMode: WildcardMode
    ) -> String {
        let fileURLPath = fileURL.path
        let baseURLPath = baseURL.path

        let standardRelativePath: String = if fileURLPath.hasPrefix(baseURLPath) {
            String(fileURLPath.dropFirst(baseURLPath.count))
        } else {
            fileURLPath
        }
        let normalizedStandardRelativePath = standardRelativePath.hasPrefix("/")
            ? String(standardRelativePath.dropFirst())
            : standardRelativePath

        switch wildcardMode {
        case .first:
            // For first mode, we want to preserve the folder structure from the first wildcard onwards
            // Pattern: */*/*/c/*.txt, File: a/b/c/file1.txt
            // Expected: a/b/c/file1.txt (preserve all components)
            return normalizedStandardRelativePath

        case .last:
            // For last mode, we want to preserve only the folder structure from the last wildcard onwards
            // Pattern: */*/*/c/*.txt, File: a/b/c/file1.txt
            // Expected: file1.txt (preserve only components from last wildcard)
            let patternComponents = filePattern.components(separatedBy: "/")
            guard let lastWildcardIndex = patternComponents.lastIndex(where: { $0.contains("*") }) else {
                return normalizedStandardRelativePath
            }

            // For last mode, we want to skip components up to the last wildcard
            // Pattern: */*/*/c/*.txt, File: a/b/c/file1.txt
            // Expected: file1.txt (skip "a/b/c" which corresponds to components up to last wildcard position)
            let relativeComponents = normalizedStandardRelativePath.components(separatedBy: "/")
            guard relativeComponents.count > lastWildcardIndex else {
                return normalizedStandardRelativePath
            }

            // Take components starting from the last wildcard index onwards
            // This gives us the components from the last wildcard position
            let lastModeComponents = Array(relativeComponents[lastWildcardIndex...])
            return lastModeComponents.joined(separator: "/")
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
