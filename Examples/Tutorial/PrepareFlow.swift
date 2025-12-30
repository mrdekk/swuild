//  Created by Denis Malykh on 30.12.2024.

import BuildsDefinitions
import Foundation
import SwuildCore

public struct PrepareFlow: Flow {
    public let name = "prepare_flow"

    public let platforms: [Platform] = [
        .iOS(version: .any),
        .macOS(version: .any),
    ]

    public let description = "Prepare flow that runs before main flow"

    public func actions(for context: Context, and platform: Platform) -> [any Action] {
        return [
            EchoAction(hint: "Prepare flow started", contentProvider: { "🔧 Prepare flow execution started" }),
            AdHocAction(hint: "Set prepare flag in context") { context, _ in
                context.put(for: "prepare_executed", option: StringOption(defaultValue: "yes"))
                print("✅ Prepare flag set in context")
            },
            ShellAction(
                hint: "Create temporary directory",
                command: "mkdir",
                arguments: [.raw(arg: "-p"), .raw(arg: ".build/temp")],
                outputToConsole: true
            ),
            EchoAction(hint: "Prepare flow completed", contentProvider: { "🔧 Prepare flow execution completed" }),
        ]
    }
}

@_cdecl("prepare")
public func prepare() -> UnsafeMutableRawPointer {
    flow { PrepareFlow() }
}