//  Created by Denis Malykh on 03.12.2024.

import Foundation
import BuildsDefinitions
import SwuildUtils

public struct Xcodebuild: Action {

    public enum OutputStyle {
        case colorized
        case raw
    }

    public let archiveTo: String? // PATH to archive (.xcarchive)
    public let workspace: String
    public let scheme: String
    public let buildSettings: [String: String]
    public let xcargs: [String: String]
    public let destination: String // TODO: proper scenario conversion
    public let destinationTimeout: TimeInterval
    public let outputStyle: OutputStyle
    public let buildLogPath: String

    public init(
        archiveTo: String? = nil,
        workspace: String,
        scheme: String,
        buildSettings: [String: String] = [:],
        xcargs: [String: String] = [:],
        destination: String,
        destinationTimeout: TimeInterval,
        outputStyle: OutputStyle,
        buildLogPath: String
    ) {
        self.archiveTo = archiveTo
        self.workspace = workspace
        self.scheme = scheme
        self.buildSettings = buildSettings
        self.xcargs = xcargs
        self.destination = destination
        self.destinationTimeout = destinationTimeout
        self.outputStyle = outputStyle
        self.buildLogPath = buildLogPath
    }

    // MARK: - BuildsDefinitions.Action

    public static let name = "xcodebuild"

    public static let description = "Run xcodebuild as action"

    public static let authors = Author.defaultAuthors

    public static func isSupported(for platform: Platform) -> Bool {
        switch platform {
        case .iOS, .macOS: return true
        }
    }

    public func execute(context: Context, platform: Platform) async throws {
        // TODO: Implement xcodebuild execution
        // For now, just return successfully
    }
}
