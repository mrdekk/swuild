//  Created by Denis Malykh on 03.10.2025.

import BuildsDefinitions
import Foundation
import SwuildCore

// MARK: - Tutorial Flow with Function Builder

@_cdecl("makeExample")
public func makeExample() -> UnsafeMutableRawPointer {
    flow { FlowBuilderExamples.makeExample() }
}

@_cdecl("makeSimpleFlow")
public func makeSimpleFlow() -> UnsafeMutableRawPointer {
    flow { FlowBuilderExamples.makeSimpleFlow() }
}

@_cdecl("makeConditionalFlow")
public func makeConditionalFlow() -> UnsafeMutableRawPointer {
    flow { FlowBuilderExamples.makeConditionalFlow() }
}

@_cdecl("makeBatchFlow")
public func makeBatchFlow() -> UnsafeMutableRawPointer {
    flow { FlowBuilderExamples.makeBatchFlow() }
}

@_cdecl("makeComplexFlow")
public func makeComplexFlow() -> UnsafeMutableRawPointer {
    flow { FlowBuilderExamples.makeComplexFlow() }
}

@_cdecl("makeNestedConditionsFlow")
public func makeNestedConditionsFlow() -> UnsafeMutableRawPointer {
    flow { FlowBuilderExamples.makeNestedConditionsFlow() }
}
