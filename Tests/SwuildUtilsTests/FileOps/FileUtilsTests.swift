//  Created by Denis Malykh on 16.10.2025.

import Foundation
import Testing
@testable import SwuildUtils

@Suite
struct FileUtilsTests {

    private var testDirectory: URL!
    private var fileManager: FileManager!
    
    init() {
        fileManager = FileManager.default
        testDirectory = URL.cachesDirectory
    }

    @Test
    func testRecursiveCopyWithSimpleFile() throws {
        let uniqueTestDir = testDirectory.appendingPathComponent("simpleFile", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)
        
        let sourceDir = uniqueTestDir.appendingPathComponent("source", isDirectory: true)
        try fileManager.createDirectory(at: sourceDir, withIntermediateDirectories: true)
        
        let sourceFile = sourceDir.appendingPathComponent("test.txt")
        try "Hello, World!".write(to: sourceFile, atomically: true, encoding: .utf8)
        
        #expect(fileManager.fileExists(atPath: sourceFile.path))
        
        let destinationDir = uniqueTestDir.appendingPathComponent("destination", isDirectory: true)
        try fileManager.createDirectory(at: destinationDir, withIntermediateDirectories: true)
        
        try FileUtils.recursiveCopy(from: sourceFile.path, to: destinationDir)
        
        let copiedFile = destinationDir.appendingPathComponent("test.txt")
        #expect(fileManager.fileExists(atPath: copiedFile.path))
        
        let content = try String(contentsOf: copiedFile)
        #expect(content == "Hello, World!")

        try fileManager.removeItem(at: uniqueTestDir)
    }
    
    @Test
    func testRecursiveCopyWithWildcardPattern() throws {
        let uniqueTestDir = testDirectory.appendingPathComponent("wildcardPattern", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)
        
        let sourceDir = uniqueTestDir.appendingPathComponent("source", isDirectory: true)
        try fileManager.createDirectory(at: sourceDir, withIntermediateDirectories: true)
        
        let txtFile = sourceDir.appendingPathComponent("test.txt")
        try "Text file content".write(to: txtFile, atomically: true, encoding: .utf8)
        
        let swiftFile = sourceDir.appendingPathComponent("test.swift")
        try "Swift file content".write(to: swiftFile, atomically: true, encoding: .utf8)
        
        let mdFile = sourceDir.appendingPathComponent("test.md")
        try "Markdown file content".write(to: mdFile, atomically: true, encoding: .utf8)
        
        let subDir = sourceDir.appendingPathComponent("subdir", isDirectory: true)
        try fileManager.createDirectory(at: subDir, withIntermediateDirectories: true)
        
        let subTxtFile = subDir.appendingPathComponent("sub.txt")
        try "Subdirectory text file".write(to: subTxtFile, atomically: true, encoding: .utf8)
        
        #expect(fileManager.fileExists(atPath: txtFile.path))
        #expect(fileManager.fileExists(atPath: swiftFile.path))
        #expect(fileManager.fileExists(atPath: mdFile.path))
        #expect(fileManager.fileExists(atPath: subTxtFile.path))
        
        let destinationDir = uniqueTestDir.appendingPathComponent("destination", isDirectory: true)
        try fileManager.createDirectory(at: destinationDir, withIntermediateDirectories: true)
        
        try FileUtils.recursiveCopy(
            from: sourceDir.appendingPathComponent("*.txt").path,
            to: destinationDir,
            outputToConsole: true
        )

        #expect(fileManager.fileExists(atPath: destinationDir.appendingPathComponent("test.txt").path))
        #expect(!fileManager.fileExists(atPath: destinationDir.appendingPathComponent("test.swift").path))
        #expect(!fileManager.fileExists(atPath: destinationDir.appendingPathComponent("test.md").path))
        #expect(!fileManager.fileExists(atPath: destinationDir.appendingPathComponent("subdir/sub.txt").path))

        // Check content of copied file
        let copiedTxtFile = destinationDir.appendingPathComponent("test.txt")
        let content = try String(contentsOf: copiedTxtFile)
        #expect(content == "Text file content")

        // test wildcard search

        try fileManager.removeItem(at: destinationDir)
        try fileManager.createDirectory(at: destinationDir, withIntermediateDirectories: true)

        try FileUtils.recursiveCopy(
            from: sourceDir.appendingPathComponent("**/*.txt").path,
            to: destinationDir,
            outputToConsole: true
        )

        #expect(!fileManager.fileExists(atPath: destinationDir.appendingPathComponent("test.txt").path))
        #expect(!fileManager.fileExists(atPath: destinationDir.appendingPathComponent("test.swift").path))
        #expect(!fileManager.fileExists(atPath: destinationDir.appendingPathComponent("test.md").path))
        #expect(fileManager.fileExists(atPath: destinationDir.appendingPathComponent("subdir/sub.txt").path))

        // test wildcard search

        try fileManager.removeItem(at: destinationDir)
        try fileManager.createDirectory(at: destinationDir, withIntermediateDirectories: true)

        try FileUtils.recursiveCopy(
            from: sourceDir.appendingPathComponent("**.txt").path,
            to: destinationDir,
            outputToConsole: true
        )

        #expect(fileManager.fileExists(atPath: destinationDir.appendingPathComponent("test.txt").path))
        #expect(!fileManager.fileExists(atPath: destinationDir.appendingPathComponent("test.swift").path))
        #expect(!fileManager.fileExists(atPath: destinationDir.appendingPathComponent("test.md").path))
        #expect(fileManager.fileExists(atPath: destinationDir.appendingPathComponent("subdir/sub.txt").path))

        try fileManager.removeItem(at: uniqueTestDir)
    }
    
    @Test
    func testRecursiveCopyWithNonExistentSource() throws {
        // Create unique test directory
        let uniqueTestDir = testDirectory.appendingPathComponent("nonExistentSource", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)
        
        let nonExistentSource = "/path/that/does/not/exist"
        let destinationDir = uniqueTestDir.appendingPathComponent("destination", isDirectory: true)
        
        #expect(throws: FileUtilsError.basePathNotFound(basePath: "/path/that/does/not/exist")) {
            try FileUtils.recursiveCopy(from: nonExistentSource, to: destinationDir)
        }

        try fileManager.removeItem(at: uniqueTestDir)
    }

    @Test
    func testRecursiveRemoveWithSimpleFile() throws {
        let uniqueTestDir = testDirectory.appendingPathComponent("simpleFileRemove", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)

        let sourceDir = uniqueTestDir.appendingPathComponent("source", isDirectory: true)
        try fileManager.createDirectory(at: sourceDir, withIntermediateDirectories: true)

        let sourceFile = sourceDir.appendingPathComponent("test.txt")
        try "Hello, World!".write(to: sourceFile, atomically: true, encoding: .utf8)

        #expect(fileManager.fileExists(atPath: sourceFile.path))

        try FileUtils.recursiveRemove(pattern: sourceFile.path)

        #expect(!fileManager.fileExists(atPath: sourceFile.path))

        try fileManager.removeItem(at: uniqueTestDir)
    }

    @Test
    func testRecursiveRemoveWithWildcardPattern() throws {
        let uniqueTestDir = testDirectory.appendingPathComponent("wildcardPatternRemove", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)

        let sourceDir = uniqueTestDir.appendingPathComponent("source", isDirectory: true)
        try fileManager.createDirectory(at: sourceDir, withIntermediateDirectories: true)

        let txtFile = sourceDir.appendingPathComponent("test.txt")
        try "Text file content".write(to: txtFile, atomically: true, encoding: .utf8)

        let swiftFile = sourceDir.appendingPathComponent("test.swift")
        try "Swift file content".write(to: swiftFile, atomically: true, encoding: .utf8)

        let mdFile = sourceDir.appendingPathComponent("test.md")
        try "Markdown file content".write(to: mdFile, atomically: true, encoding: .utf8)

        let subDir = sourceDir.appendingPathComponent("subdir", isDirectory: true)
        try fileManager.createDirectory(at: subDir, withIntermediateDirectories: true)

        let subTxtFile = subDir.appendingPathComponent("sub.txt")
        try "Subdirectory text file".write(to: subTxtFile, atomically: true, encoding: .utf8)

        #expect(fileManager.fileExists(atPath: txtFile.path))
        #expect(fileManager.fileExists(atPath: swiftFile.path))
        #expect(fileManager.fileExists(atPath: mdFile.path))
        #expect(fileManager.fileExists(atPath: subTxtFile.path))

        try FileUtils.recursiveRemove(
            pattern: sourceDir.appendingPathComponent("*.txt").path,
            outputToConsole: true
        )

        #expect(!fileManager.fileExists(atPath: txtFile.path))
        #expect(fileManager.fileExists(atPath: swiftFile.path))
        #expect(fileManager.fileExists(atPath: mdFile.path))
        #expect(fileManager.fileExists(atPath: subTxtFile.path))

        try "Text file content".write(to: txtFile, atomically: true, encoding: .utf8)
        #expect(fileManager.fileExists(atPath: txtFile.path))

        try FileUtils.recursiveRemove(
            pattern: sourceDir.appendingPathComponent("**/*.txt").path,
            outputToConsole: true
        )

        #expect(fileManager.fileExists(atPath: txtFile.path))
        #expect(fileManager.fileExists(atPath: swiftFile.path))
        #expect(fileManager.fileExists(atPath: mdFile.path))
        #expect(!fileManager.fileExists(atPath: subTxtFile.path))

        try FileUtils.recursiveRemove(
            pattern: sourceDir.appendingPathComponent("**.txt").path,
            outputToConsole: true
        )

        #expect(!fileManager.fileExists(atPath: txtFile.path))
        #expect(fileManager.fileExists(atPath: swiftFile.path))
        #expect(fileManager.fileExists(atPath: mdFile.path))
        #expect(!fileManager.fileExists(atPath: subTxtFile.path))

        try fileManager.removeItem(at: uniqueTestDir)
    }

    @Test
    func testRecursiveRemoveWithNonExistentSource() throws {
        let uniqueTestDir = testDirectory.appendingPathComponent("nonExistentSourceRemove", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)

        let nonExistentSource = "/path/that/does/not/exist"

        #expect(throws: FileUtilsError.basePathNotFound(basePath: "/path/that/does/not/exist")) {
            try FileUtils.recursiveRemove(pattern: nonExistentSource)
        }

        try fileManager.removeItem(at: uniqueTestDir)
    }
}
