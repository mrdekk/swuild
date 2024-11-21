//  Created by Denis Malykh on 21.11.2024.

import BuildsDefinitions
import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public enum FlowBuildableMacroError: Error, CustomStringConvertible {
    case noTypeArgument
    case firstArgumentShouldBeFlow
    case unknown(message: String)

    public var description: String {
        switch self {
        case .noTypeArgument: "First argument should be type"
        case .firstArgumentShouldBeFlow: "First argument of flowBuildable macro should be Flow.type"
        case let .unknown(message): message
        }
    }
}

public struct FlowBuildableMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        guard let expr = node.arguments.first?.description else {
            throw FlowBuildableMacroError.noTypeArgument
        }

        let extensionDecl = """
        final class ModuleFlowBuilder: FlowBuilder {
            override func build() -> any Flow {
                \(expr)()
            }
        }

        @_cdecl("makeFlow")
        public func makeFlow() -> UnsafeMutableRawPointer {
            return Unmanaged.passRetained(ModuleFlowBuilder()).toOpaque()
        }
        """

        return [
            DeclSyntax(stringLiteral: extensionDecl)
        ]
    }
}
