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
    func testRecursiveCopyWithWildcardMode() throws {
        let uniqueTestDir = testDirectory.appendingPathComponent("wildcardMode", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)

        let sourceDir = uniqueTestDir.appendingPathComponent("source", isDirectory: true)
        try fileManager.createDirectory(at: sourceDir, withIntermediateDirectories: true)

        // Create directories: source/a/b/c/
        let dirA = sourceDir.appendingPathComponent("a", isDirectory: true)
        try fileManager.createDirectory(at: dirA, withIntermediateDirectories: true)

        let dirB = dirA.appendingPathComponent("b", isDirectory: true)
        try fileManager.createDirectory(at: dirB, withIntermediateDirectories: true)

        let dirC = dirB.appendingPathComponent("c", isDirectory: true)
        try fileManager.createDirectory(at: dirC, withIntermediateDirectories: true)

        let file1 = dirC.appendingPathComponent("file1.txt")
        try "File 1 content".write(to: file1, atomically: true, encoding: .utf8)

        let file2 = dirB.appendingPathComponent("file2.txt")
        try "File 2 content".write(to: file2, atomically: true, encoding: .utf8)

        #expect(fileManager.fileExists(atPath: file1.path))
        #expect(fileManager.fileExists(atPath: file2.path))

        let destinationDir1 = uniqueTestDir.appendingPathComponent("destination1", isDirectory: true)
        try fileManager.createDirectory(at: destinationDir1, withIntermediateDirectories: true)

        try FileUtils.recursiveCopy(
            from: sourceDir.appendingPathComponent("*/*/c/*.txt").path,
            to: destinationDir1,
            outputToConsole: true,
            wildcardMode: .first
        )

        #expect(fileManager.fileExists(atPath: destinationDir1.appendingPathComponent("a/b/c/file1.txt").path))

        let copiedFile1First = destinationDir1.appendingPathComponent("a/b/c/file1.txt")
        let content1First = try String(contentsOf: copiedFile1First)
        #expect(content1First == "File 1 content")

        let destinationDir2 = uniqueTestDir.appendingPathComponent("destination2", isDirectory: true)
        try fileManager.createDirectory(at: destinationDir2, withIntermediateDirectories: true)

        try FileUtils.recursiveCopy(
            from: sourceDir.appendingPathComponent("*/*/c/*.txt").path,
            to: destinationDir2,
            outputToConsole: true,
            wildcardMode: .last
        )

        #expect(fileManager.fileExists(atPath: destinationDir2.appendingPathComponent("file1.txt").path))

        let copiedFile1Last = destinationDir2.appendingPathComponent("file1.txt")
        let content1Last = try String(contentsOf: copiedFile1Last)
        #expect(content1Last == "File 1 content")

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
    func testRecursiveRemoveWithDirectories() throws {
        let uniqueTestDir = testDirectory.appendingPathComponent("directoryRemove", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)

        let sourceDir = uniqueTestDir.appendingPathComponent("source", isDirectory: true)
        try fileManager.createDirectory(at: sourceDir, withIntermediateDirectories: true)

        // Create directory structure:
        // source/
        //   dir1/
        //     file1.txt
        //   dir2/
        //     subdir/
        //       file2.txt
        //     file3.txt
        //   file4.txt

        let dir1 = sourceDir.appendingPathComponent("dir1", isDirectory: true)
        try fileManager.createDirectory(at: dir1, withIntermediateDirectories: true)
        let file1 = dir1.appendingPathComponent("file1.txt")
        try "File 1 content".write(to: file1, atomically: true, encoding: .utf8)

        let dir2 = sourceDir.appendingPathComponent("dir2", isDirectory: true)
        try fileManager.createDirectory(at: dir2, withIntermediateDirectories: true)
        let subdir = dir2.appendingPathComponent("subdir", isDirectory: true)
        try fileManager.createDirectory(at: subdir, withIntermediateDirectories: true)
        let file2 = subdir.appendingPathComponent("file2.txt")
        try "File 2 content".write(to: file2, atomically: true, encoding: .utf8)
        let file3 = dir2.appendingPathComponent("file3.txt")
        try "File 3 content".write(to: file3, atomically: true, encoding: .utf8)

        let file4 = sourceDir.appendingPathComponent("file4.txt")
        try "File 4 content".write(to: file4, atomically: true, encoding: .utf8)

        #expect(fileManager.fileExists(atPath: dir1.path))
        #expect(fileManager.fileExists(atPath: file1.path))
        #expect(fileManager.fileExists(atPath: dir2.path))
        #expect(fileManager.fileExists(atPath: subdir.path))
        #expect(fileManager.fileExists(atPath: file2.path))
        #expect(fileManager.fileExists(atPath: file3.path))
        #expect(fileManager.fileExists(atPath: file4.path))

        try FileUtils.recursiveRemove(
            pattern: sourceDir.appendingPathComponent("dir1/**").path,
            outputToConsole: true
        )

        #expect(fileManager.fileExists(atPath: dir1.path))
        #expect(!fileManager.fileExists(atPath: file1.path))

        #expect(fileManager.fileExists(atPath: dir2.path))
        #expect(fileManager.fileExists(atPath: subdir.path))
        #expect(fileManager.fileExists(atPath: file2.path))
        #expect(fileManager.fileExists(atPath: file3.path))
        #expect(fileManager.fileExists(atPath: file4.path))

        try FileUtils.recursiveRemove(
            pattern: sourceDir.appendingPathComponent("**/subdir/**").path,
            outputToConsole: true
        )

        #expect(fileManager.fileExists(atPath: subdir.path))
        #expect(!fileManager.fileExists(atPath: file2.path))

        #expect(fileManager.fileExists(atPath: dir2.path))
        #expect(fileManager.fileExists(atPath: file3.path))
        #expect(fileManager.fileExists(atPath: file4.path))

        try FileUtils.recursiveRemove(pattern: sourceDir.path)

        #expect(!fileManager.fileExists(atPath: sourceDir.path))

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
