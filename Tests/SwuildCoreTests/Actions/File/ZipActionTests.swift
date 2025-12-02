//  Created by Denis Malykh on 02.12.2025.

import Foundation
import Testing
import SwuildUtils

@testable import SwuildCore
@testable import BuildsDefinitions

@Suite
struct ZipActionTests {
    
    private var testDirectory: URL!
    private var fileManager: FileManager!
    
    init() {
        fileManager = FileManager.default
        testDirectory = URL.cachesDirectory
    }
    
    @Test
    func testZipActionNameAndDescription() {
        #expect(ZipAction.name == "zip")
        #expect(!ZipAction.description.isEmpty)
    }
    
    @Test
    func testZipActionBasicZip() async throws {
        guard let _ = try? sh(command: "which", parameters: ["zip"], captureOutput: true) else {
            print("zip command not available, skipping test")
            return
        }
        
        let uniqueTestDir = testDirectory.appendingPathComponent("zipActionBasicZip", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)
        
        let sourceDir = uniqueTestDir.appendingPathComponent("source", isDirectory: true)
        try fileManager.createDirectory(at: sourceDir, withIntermediateDirectories: true)
        
        let sourceFile = sourceDir.appendingPathComponent("test.txt")
        try "Hello, World!".write(to: sourceFile, atomically: true, encoding: .utf8)
        
        #expect(fileManager.fileExists(atPath: sourceFile.path))
        
        let zipPath = uniqueTestDir.appendingPathComponent("test.zip").path
        
        let params = ZipParams(
            path: sourceDir.path,
            outputPath: zipPath,
            verbose: false,
            workingDirectory: uniqueTestDir.path
        )
        
        let action = ZipAction(params: params)
        let context = MockContext()
        
        try await action.execute(context: context, platform: .macOS(version: .any))
        
        #expect(fileManager.fileExists(atPath: zipPath))
        
        try fileManager.removeItem(at: uniqueTestDir)
    }
    
    @Test
    func testZipActionWithExclude() async throws {
        guard let _ = try? sh(command: "which", parameters: ["zip"], captureOutput: true) else {
            print("zip command not available, skipping test")
            return
        }
        
        let uniqueTestDir = testDirectory.appendingPathComponent("zipActionWithExclude", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)
        
        let sourceDir = uniqueTestDir.appendingPathComponent("source", isDirectory: true)
        try fileManager.createDirectory(at: sourceDir, withIntermediateDirectories: true)
        
        let txtFile = sourceDir.appendingPathComponent("test.txt")
        try "Text file content".write(to: txtFile, atomically: true, encoding: .utf8)
        
        let logFile = sourceDir.appendingPathComponent("test.log")
        try "Log file content".write(to: logFile, atomically: true, encoding: .utf8)
        
        #expect(fileManager.fileExists(atPath: txtFile.path))
        #expect(fileManager.fileExists(atPath: logFile.path))
        
        let zipPath = uniqueTestDir.appendingPathComponent("test.zip").path
        
        let params = ZipParams(
            path: sourceDir.path,
            outputPath: zipPath,
            verbose: false,
            exclude: ["*.log"],
            workingDirectory: uniqueTestDir.path
        )
        
        let action = ZipAction(params: params)
        let context = MockContext()
        
        try await action.execute(context: context, platform: .macOS(version: .any))
        
        #expect(fileManager.fileExists(atPath: zipPath))
        
        // Note: We're not verifying the contents of the zip file here
        // A full test would require unzipping and checking contents
        
        try fileManager.removeItem(at: uniqueTestDir)
    }
    
    @Test
    func testZipActionSourceNotExists() async throws {
        guard let _ = try? sh(command: "which", parameters: ["zip"], captureOutput: true) else {
            print("zip command not available, skipping test")
            return
        }
        
        let uniqueTestDir = testDirectory.appendingPathComponent("zipActionSourceNotExists", isDirectory: true)
        try fileManager.createDirectory(at: uniqueTestDir, withIntermediateDirectories: true)
        
        let nonExistentPath = uniqueTestDir.appendingPathComponent("nonexistent", isDirectory: true).path
        let zipPath = uniqueTestDir.appendingPathComponent("test.zip").path
        
        let params = ZipParams(
            path: nonExistentPath,
            outputPath: zipPath,
            verbose: false,
            workingDirectory: uniqueTestDir.path
        )
        
        let action = ZipAction(params: params)
        let context = MockContext()
        
        await #expect(throws: ZipAction.Errors.self) {
            try await action.execute(context: context, platform: .macOS(version: .any))
        }
        
        try fileManager.removeItem(at: uniqueTestDir)
    }
}

extension ZipAction.Errors: Equatable {
    public static func == (lhs: ZipAction.Errors, rhs: ZipAction.Errors) -> Bool {
        switch (lhs, rhs) {
        case (.sourceFileNotExists, .sourceFileNotExists):
            return true
        case (.zipNotInstalled, .zipNotInstalled):
            return true
        case (.executionFailed(let lhsMessage), .executionFailed(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
