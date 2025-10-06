//  Created by Denis Malykh on 22.11.2024.

import BuildsDefinitions
import Foundation

typealias InitFunction = @convention(c) () -> UnsafeMutableRawPointer

enum PluginErrors: Error {
    case libraryLoadingError(message: String)
    case symbolLoadingError
    case pluginIsNotLoaded
}

final class Plugin {

    private let path: String

    private var resourceHandler: UnsafeMutableRawPointer?

    init(path: String) {
        self.path = path
    }

    deinit {
        if resourceHandler != nil {
            unload()
        }
    }

    func loadLibrary() throws {
        let openRes = dlopen(path, RTLD_NOW | RTLD_LOCAL)
        guard let openRes else {
            if let err = dlerror() {
                throw PluginErrors.libraryLoadingError(message: String(format: "%s", err))
            } else {
                throw PluginErrors.libraryLoadingError(message: "Unknown loading error")
            }
        }
        
        resourceHandler = openRes
    }

    func makeFlowBuilder(functionName: String = "makeFlow") throws -> FlowBuilder {
        guard let resourceHandler else {
            throw PluginErrors.libraryLoadingError(message: "Library not loaded")
        }

        let sym = dlsym(resourceHandler, functionName)

        guard let sym else {
            throw PluginErrors.symbolLoadingError
        }

        let f: InitFunction = unsafeBitCast(sym, to: InitFunction.self)
        let flowPointer = f()
        return Unmanaged<FlowBuilder>.fromOpaque(flowPointer).takeRetainedValue()
    }

    func unload() {
        if let resourceHandler {
            dlclose(resourceHandler)
            self.resourceHandler = nil
        }
    }
}
