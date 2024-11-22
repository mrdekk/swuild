//  Created by Denis Malykh on 20.11.2024.

import ArgumentParser
import BuildsDefinitions
import Foundation
import SwuildCore
import SwuildUtils

struct Run: AsyncParsableCommand {

    enum Errors: Error {
        case noSuchProductDefinition
    }

    @ArgumentParser.Option(
        name: .shortAndLong,
        help: "Directory where Package.swift of Flow definition is located"
    )
    var inputFolder = FileManager.default.currentDirectoryPath

    @ArgumentParser.Option(
        name: .shortAndLong,
        help: "Product name of Flow definition"
    )
    var flowName: String = "Flow"

    @ArgumentParser.Option(
        name: .shortAndLong,
        help: "Print resulting content after build execution"
    )
    var printResultContext: Bool = false

    mutating func run() async throws {
        do {
            let builder = PackageBuilder()
            let binary = try await builder.buildPackage(at: inputFolder, productName: flowName)

            let plugin = Plugin(path: binary)
            try plugin.load()
            let flow = try plugin.build()

            let context = makeContext()
            let result = try await flow.execute(context: context)

            print("Result is \(result)")
            if printResultContext, let impl = context as? ContextPrintable {
                impl.printContext()
            }
        } catch {
            print("Error is \(error)")
        }
    }
}

extension Flow {
    func execute(context: Context) async throws -> Result<Void, FlowErrors> {
        do {
            for platform in platforms {
                for action in actions {
                    guard type(of: action).isSupported(for: platform) else {
                        continue
                    }

                    let result = try await action.execute(context: context)
                    switch result {
                    case .success:
                        break
                    case let .failure(error):
                        throw FlowErrors.actionExecution(cause: error)
                    }
                }
            }
            return .success(())
        } catch {
            return .failure(.actionExecution(cause: error))
        }
    }
}
