//  Created by Denis Malykh on 21.11.2024.

import Foundation

@freestanding(declaration, names: named(ModuleFlowBuilder), named(makeFlow))
public macro flowBuildable<T>(_ type: T.Type) = #externalMacro(module: "FlowBuildableMacro", type: "FlowBuildableMacro")
