//  Created by Denis Malykh on 20.11.2024.

import ArgumentParser
import BuildsDefinitions
import Foundation
import SwuildCore

struct Run: AsyncParsableCommand {
    mutating func run() async throws {
        do {
            let flow = try flow(at: "/Users/mrdekk/AppR/swuild/libTutorial.dylib")
            let context = makeContext()
            let result = try await flow.execute(context: context)
            print("Result is \(result)")
        } catch {

        }
    }
}

enum RunErrors: Error {
    case libraryLoadingError(message: String)
    case symbolLoadingError
}

typealias InitFunction = @convention(c) () -> UnsafeMutableRawPointer

private func flow(at path: String) throws -> Flow {
    let openRes = dlopen(path, RTLD_NOW | RTLD_LOCAL)
    guard let openRes else {
        if let err = dlerror() {
            throw RunErrors.libraryLoadingError(message: String(format: "%s", err))
        } else {
            throw RunErrors.libraryLoadingError(message: "Unknown loading error")
        }
    }

//    defer {
//        dlclose(openRes)
//    }

    let symbolName = "makeFlow"
    let sym = dlsym(openRes, symbolName)

    guard let sym else {
        throw RunErrors.symbolLoadingError
    }

    let f: InitFunction = unsafeBitCast(sym, to: InitFunction.self)
    let flowPointer = f()
    let builder = Unmanaged<FlowBuilder>.fromOpaque(flowPointer).takeRetainedValue()
    return builder.build()
}
