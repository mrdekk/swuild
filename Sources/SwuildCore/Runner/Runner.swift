//  Created by Denis Malykh on 23.10.2025.

import BuildsDefinitions

public enum RunnerErrors: Error {
    case invalidContextParameter(String)
}

public protocol Runner {
    func run(flow: Flow) async throws -> Context
}

final class RunnerImpl: Runner {
    private let contextValues: [String]
    private let printResultContext: Bool
    private let displayExecutionSummary: Bool

    init(
        contextValues: [String],
        printResultContext: Bool,
        displayExecutionSummary: Bool
    ) {
        self.contextValues = contextValues
        self.printResultContext = printResultContext
        self.displayExecutionSummary = displayExecutionSummary
    }

    public func run(flow: Flow) async throws -> Context {
        let context = try createContext()
        let summaries = try await flow.execute(context: context)

        if displayExecutionSummary {
            print("✅ Flow executed successfully is")
            summaries.displayExecutionSummary()
        }

        if printResultContext, let impl = context as? ContextPrintable {
            impl.printContext()
        }

        return context
    }

    /// Creates a context and populates it with values from command line options
    /// - Returns: A new context with command line values added
    private func createContext() throws -> Context {
        let context = makeContext()

        for contextValue in contextValues {
            let parts = contextValue.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            if parts.count == 2 {
                let key = String(parts[0])
                let value = String(parts[1])
                context.put(for: key, option: StringOption(defaultValue: value))
            } else {
                print("Invalid context value format: \(contextValue). Expected format: key=value")
                throw RunnerErrors.invalidContextParameter(contextValue)
            }
        }

        return context
    }

}

public func makeRunner(
    contextValues: [String],
    printResultContext: Bool,
    displayExecutionSummary: Bool
) -> Runner {
    RunnerImpl(
        contextValues: contextValues,
        printResultContext: printResultContext,
        displayExecutionSummary: displayExecutionSummary
    )
}
