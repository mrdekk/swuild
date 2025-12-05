//  Created by Denis Malykh on 05.12.2025.

import Foundation
import Testing

@testable import iSwuild
@testable import SwuildCore
@testable import BuildsDefinitions

@Suite
struct XcodeSelectTests {
    
    @Test
    func testXcodeSelectActionNameAndDescription() {
        #expect(XcodeSelect.name == "xcode_select")
        #expect(!XcodeSelect.description.isEmpty)
    }
    
    @Test
    func testXcodeSelectActionWithMissingPath() async throws {
        let params = XcodeSelectParams(xcodePath: "")
        let action = XcodeSelect(params: params)
        let context = MockContext()
        
        await #expect(throws: XcodeSelect.Errors.self) {
            try await action.execute(context: context, platform: .macOS(version: .any))
        }
    }
    
    @Test
    func testXcodeSelectActionWithNonExistentPath() async throws {
        let nonExistentPath = "/path/that/does/not/exist"
        let params = XcodeSelectParams(xcodePath: nonExistentPath)
        let action = XcodeSelect(params: params)
        let context = MockContext()
        
        await #expect(throws: XcodeSelect.Errors.self) {
            try await action.execute(context: context, platform: .macOS(version: .any))
        }
    }
    
    @Test
    func testXcodeSelectActionWithFileInsteadOfDirectory() async throws {
        // Use a known existing file for testing
        let filePath = "/etc/hosts"
        
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory) else {
            throw TestError("Test requires /etc/hosts file to exist")
        }
        
        // Verify it's a file, not a directory
        guard !isDirectory.boolValue else {
            throw TestError("Expected /etc/hosts to be a file, not a directory")
        }
        
        let params = XcodeSelectParams(xcodePath: filePath)
        let action = XcodeSelect(params: params)
        let context = MockContext()
        
        await #expect(throws: XcodeSelect.Errors.self) {
            try await action.execute(context: context, platform: .macOS(version: .any))
        }
    }
}

struct TestError: Error, LocalizedError {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var errorDescription: String? {
        return message
    }
}
