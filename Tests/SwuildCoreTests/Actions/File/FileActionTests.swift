//  Created by Denis Malykh on 16.10.2025.

import Foundation
import Testing

@testable import SwuildCore
@testable import BuildsDefinitions

@Suite
struct FileActionTests {

    private var testDirectory: URL!
    private var fileManager: FileManager!
    
    init() {
        fileManager = FileManager.default
        testDirectory =  URL.cachesDirectory
    }

    @Test
    func testFileActionNameAndDescription() {
        #expect(FileAction.name == "file")
        #expect(!FileAction.description.isEmpty)
    }
    
    @Test
    func testFileActionCopyJob() async throws {
        let uniqueTestDir = testDirectory.appendingPathComponent("copyJob", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)
        
        let sourceDir = uniqueTestDir.appendingPathComponent("source", isDirectory: true)
        try fileManager.createDirectory(at: sourceDir, withIntermediateDirectories: true)
        
        let sourceFile = sourceDir.appendingPathComponent("test.txt")
        try "Hello, World!".write(to: sourceFile, atomically: true, encoding: .utf8)
        
        #expect(fileManager.fileExists(atPath: sourceFile.path))
        
        let destinationDir = uniqueTestDir.appendingPathComponent("destination", isDirectory: true)
        try fileManager.createDirectory(at: destinationDir, withIntermediateDirectories: true)
        
        let action = FileAction(
            job: .copy(from: .raw(arg: sourceFile.path), to: .raw(arg: destinationDir.path), wildcardMode: .first)
        )
        let context = MockContext()
        
        try await action.execute(context: context, platform: .macOS(version: .any))
        
        let copiedFile = destinationDir.appendingPathComponent("test.txt")
        #expect(fileManager.fileExists(atPath: copiedFile.path))
        
        let content = try String(contentsOf: copiedFile)
        #expect(content == "Hello, World!")

        try fileManager.removeItem(at: uniqueTestDir)
    }
    
    @Test
    func testFileActionCopyJobWithWildcard() async throws {
        let uniqueTestDir = testDirectory.appendingPathComponent("copyJobWithWildcard", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)
        
        let sourceDir = uniqueTestDir.appendingPathComponent("source", isDirectory: true)
        try fileManager.createDirectory(at: sourceDir, withIntermediateDirectories: true)
        
        let txtFile = sourceDir.appendingPathComponent("test.txt")
        try "Text file content".write(to: txtFile, atomically: true, encoding: .utf8)
        
        let swiftFile = sourceDir.appendingPathComponent("test.swift")
        try "Swift file content".write(to: swiftFile, atomically: true, encoding: .utf8)
        
        #expect(fileManager.fileExists(atPath: txtFile.path))
        #expect(fileManager.fileExists(atPath: swiftFile.path))
        
        let destinationDir = uniqueTestDir.appendingPathComponent("destination", isDirectory: true)
        try fileManager.createDirectory(at: destinationDir, withIntermediateDirectories: true)
        
        let action = FileAction(
            job: .copy(
                from: .raw(arg: sourceDir.appendingPathComponent("*.txt").path),
                to: .raw(arg: destinationDir.path),
                wildcardMode: .first
            )
        )
        let context = MockContext()
        
        try await action.execute(context: context, platform: .macOS(version: .any))
        
        #expect(fileManager.fileExists(atPath: destinationDir.appendingPathComponent("test.txt").path))
        #expect(!fileManager.fileExists(atPath: destinationDir.appendingPathComponent("test.swift").path))
        
        let copiedTxtFile = destinationDir.appendingPathComponent("test.txt")
        let content = try String(contentsOf: copiedTxtFile)
        #expect(content == "Text file content")

        try fileManager.removeItem(at: uniqueTestDir)
    }
    
    @Test
    func testFileActionCopyJobWithContextKey() async throws {
        let uniqueTestDir = testDirectory.appendingPathComponent("copyJobWithContextKey", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)
        
        let sourceDir = uniqueTestDir.appendingPathComponent("source", isDirectory: true)
        try fileManager.createDirectory(at: sourceDir, withIntermediateDirectories: true)
        
        let sourceFile = sourceDir.appendingPathComponent("test.txt")
        try "Hello, World!".write(to: sourceFile, atomically: true, encoding: .utf8)
        
        #expect(fileManager.fileExists(atPath: sourceFile.path))
        
        let destinationDir = uniqueTestDir.appendingPathComponent("destination", isDirectory: true)
        try fileManager.createDirectory(at: destinationDir, withIntermediateDirectories: true)
        
        let action = FileAction(
            job: .copy(from: .key(key: "sourceFile"), to: .raw(arg: destinationDir.path), wildcardMode: .first)
        )
        let context = MockContext()
        context.setArgument("sourceFile", value: sourceFile.path)
        
        try await action.execute(context: context, platform: .macOS(version: .any))
        
        let copiedFile = destinationDir.appendingPathComponent("test.txt")
        #expect(fileManager.fileExists(atPath: copiedFile.path))
        
        let content = try String(contentsOf: copiedFile)
        #expect(content == "Hello, World!")

        try fileManager.removeItem(at: uniqueTestDir)
    }
    
    @Test
    func testFileActionCopyJobWithMissingContextKey() async throws {
        let action = FileAction(
            job: .copy(from: .key(key: "missingKey"), to: .raw(arg: "/destination"), wildcardMode: .first)
        )
        let context = MockContext()
        
        await #expect(throws: FileAction.Errors.self) {
            try await action.execute(context: context, platform: .macOS(version: .any))
        }
    }
    
    @Test
    func testFileActionMakeDirectoryJob() async throws {
        let uniqueTestDir = testDirectory.appendingPathComponent("makeDirectoryJob", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)
        
        let destinationDir = uniqueTestDir.appendingPathComponent("newDirectory", isDirectory: true)
        let action = FileAction(
            job: .makeDirectory(path: .raw(arg: destinationDir.path), ensureCreated: false)
        )
        let context = MockContext()
        
        try await action.execute(context: context, platform: .macOS(version: .any))
        
        #expect(fileManager.fileExists(atPath: destinationDir.path))

        try fileManager.removeItem(at: uniqueTestDir)
    }
    
    @Test
    func testFileActionMakeDirectoryJobWithEnsureCreated() async throws {
        let uniqueTestDir = testDirectory
            .appendingPathComponent("makeDirectoryJobWithEnsureCreated", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)
        
        let destinationDir = uniqueTestDir.appendingPathComponent("newDirectory", isDirectory: true)
        let action = FileAction(
            job: .makeDirectory(path: .raw(arg: destinationDir.path), ensureCreated: true)
        )
        let context = MockContext()
        
        try await action.execute(context: context, platform: .macOS(version: .any))
        
        #expect(fileManager.fileExists(atPath: destinationDir.path))

        try fileManager.removeItem(at: uniqueTestDir)
    }
    
    @Test
    func testFileActionRecreateDirectoryJob() async throws {
        let uniqueTestDir = testDirectory.appendingPathComponent("recreateDirectoryJob", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)
        
        let existingDir = uniqueTestDir.appendingPathComponent("existing", isDirectory: true)
        try fileManager.createDirectory(at: existingDir, withIntermediateDirectories: true)
        
        let existingFile = existingDir.appendingPathComponent("existing.txt")
        try "Existing content".write(to: existingFile, atomically: true, encoding: .utf8)
        
        #expect(fileManager.fileExists(atPath: existingDir.path))
        #expect(fileManager.fileExists(atPath: existingFile.path))
        
        let action = FileAction(
            job: .recreateDirectory(path: .raw(arg: existingDir.path), ensureCreated: true)
        )
        let context = MockContext()
        
        try await action.execute(context: context, platform: .macOS(version: .any))
        
        #expect(fileManager.fileExists(atPath: existingDir.path))

        let files = try fileManager.contentsOfDirectory(at: existingDir, includingPropertiesForKeys: nil)
        #expect(files.isEmpty)

        try fileManager.removeItem(at: uniqueTestDir)
    }

    @Test
    func testFileActionRemoveDirectoryJob() async throws {
        let uniqueTestDir = testDirectory.appendingPathComponent("removeDirectoryJob", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)

        let directoryToRemove = uniqueTestDir.appendingPathComponent("toRemove", isDirectory: true)
        try fileManager.createDirectory(at: directoryToRemove, withIntermediateDirectories: true)

        let fileInDirectory = directoryToRemove.appendingPathComponent("file.txt")
        try "File content".write(to: fileInDirectory, atomically: true, encoding: .utf8)

        #expect(fileManager.fileExists(atPath: directoryToRemove.path))
        #expect(fileManager.fileExists(atPath: fileInDirectory.path))

        let action = FileAction(
            job: .removeDirectory(path: .raw(arg: directoryToRemove.path))
        )
        let context = MockContext()

        try await action.execute(context: context, platform: .macOS(version: .any))

        #expect(!fileManager.fileExists(atPath: directoryToRemove.path))

        try fileManager.removeItem(at: uniqueTestDir)
    }

    @Test
    func testFileActionRemoveDirectoryJobWithWildcard() async throws {
        let uniqueTestDir = testDirectory.appendingPathComponent("removeDirectoryJobWithWildcard", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)

        let sourceDir = uniqueTestDir.appendingPathComponent("source", isDirectory: true)
        try fileManager.createDirectory(at: sourceDir, withIntermediateDirectories: true)

        let txtFile = sourceDir.appendingPathComponent("test.txt")
        try "Text file content".write(to: txtFile, atomically: true, encoding: .utf8)

        let swiftFile = sourceDir.appendingPathComponent("test.swift")
        try "Swift file content".write(to: swiftFile, atomically: true, encoding: .utf8)

        #expect(fileManager.fileExists(atPath: txtFile.path))
        #expect(fileManager.fileExists(atPath: swiftFile.path))

        let action = FileAction(
            job: .removeDirectory(path: .raw(arg: sourceDir.appendingPathComponent("*.txt").path)),
            outputToConsole: false
        )
        let context = MockContext()

        try await action.execute(context: context, platform: .macOS(version: .any))

        #expect(!fileManager.fileExists(atPath: txtFile.path))
        #expect(fileManager.fileExists(atPath: swiftFile.path))

        try fileManager.removeItem(at: uniqueTestDir)
    }
}

private class MockContext: Context {
    private var arguments: [String: Any] = [:]

    func put<T>(for key: String, option: OptionValue<T>) {
        arguments[key] = option.value
    }

    func get<T>(for key: String) -> T? {
        return arguments[key] as? T
    }

    func drop(_ key: String) -> Bool {
        let contains = arguments[key] != nil
        arguments.removeValue(forKey: key)
        return contains
    }

    func setArgument<T>(_ key: String, value: T) {
        arguments[key] = value
    }

    func getArgument(_ key: String) -> String? {
        return arguments[key] as? String
    }
}
