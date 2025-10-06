//  Created by Denis Malykh on 03.10.2025.

import Foundation

@freestanding(declaration, names: named(ModuleFlowBuilder), named(makeFlow))
public macro flowBuildableWithFactory(_ flowType: Any.Type, _ factoryMethod: String = "makeExample") = #externalMacro(module: "FlowBuildableMacro", type: "FlowBuildableWithFactoryMacro")
