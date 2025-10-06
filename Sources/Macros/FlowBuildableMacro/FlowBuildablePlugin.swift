//  Created by Denis Malykh on 21.11.2024.

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct FlowBuildablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FlowBuildableMacro.self,
        FlowBuildableWithFactoryMacro.self,
    ]
}
