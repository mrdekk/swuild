//  Created by Denis Malykh on 03.10.2025.

import BuildsDefinitions
import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public enum FlowBuildableWithFactoryMacroError: Error, CustomStringConvertible {
    case noTypeArgument
    case noFactoryMethodArgument
    case firstArgumentShouldBeFlow
    case unknown(message: String)
    
    public var description: String {
        switch self {
        case .noTypeArgument: "First argument should be type"
        case .noFactoryMethodArgument: "Second argument should be factory method name"
        case .firstArgumentShouldBeFlow: "First argument of flowBuildableWithFactory macro should be Flow.type"
        case let .unknown(message): message
        }
    }
}

public struct FlowBuildableWithFactoryMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        guard node.arguments.count >= 2 else {
            throw FlowBuildableWithFactoryMacroError.noFactoryMethodArgument
        }
        
        let arguments = node.arguments.map { $0 }
        let firstArgument = arguments[0]
        let secondArgument = arguments[1]
        
        let flowType = firstArgument.expression.description.replacingOccurrences(of: ".self", with: "")
        guard let stringLiteral = secondArgument.expression.as(StringLiteralExprSyntax.self) else {
            throw FlowBuildableWithFactoryMacroError.noFactoryMethodArgument
        }
        
        let factoryMethod = stringLiteral.segments.first?.description ?? "makeExample"
        
        let extensionDecl = """
        final class ModuleFlowBuilder: FlowBuilder {
            override func build() -> any Flow {
                return \(flowType).\(factoryMethod)()
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
