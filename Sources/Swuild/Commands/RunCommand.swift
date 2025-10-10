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
    var flowProductName: String = "Flow"

    @ArgumentParser.Option(
        name: .shortAndLong,
        help: "Print resulting content after build execution"
    )
    var printResultContext: Bool = false

    @ArgumentParser.Option(
        name: .customLong("context-value"),
        help: "Add a key-value pair to the context (can be used multiple times)"
    )
    var contextValues: [String] = []

    @ArgumentParser.Option(
        name: .long,
        help: "Function name to create flow builder"
    )
    var functionName: String = "makeFlow"

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
                throw ExitCode.failure
            }
        }

        return context
    }

    mutating func run() async throws {
        do {
            print("Swuild Build")
            print("  input folder: \(inputFolder)")
            print("  flow name: \(flowProductName)")
            print("  function name: \(functionName)")
            print("  print result context: \(printResultContext)")

            let buildContext = try createContext()
            let buildFlow = RunFlow(productName: flowProductName, inputFolder: inputFolder)
            let buildResult = try await buildFlow.execute(context: buildContext)
            guard
                case .success = buildResult,
                let flowPlugingPath: String = buildContext.get(for: kFlowPluginKey)
            else {
                throw PackageBuilderErrors.genericBuildError(message: "build flow execution failure: \(buildResult)")
            }

            let plugin = Plugin(path: flowPlugingPath)
            try plugin.loadLibrary()
            let flowBuilder = try plugin.makeFlowBuilder(functionName: functionName)
            let flow = flowBuilder.build()

            let context = try createContext()
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

enum PackageBuilderErrors: Error {
    case noSuchProductDefinition
    case binaryProductMissing
    case genericBuildError(message: String)
}

private struct RunFlow: Flow {
    public let name = "swuild_run_flow"

    public let platforms: [Platform] = [
        .macOS(version: .any),
    ]

    public let description = "Flow to run swuild flows"

    public var actions: [any Action] {
        [
            SPMAction(job: .gatherPackageDump(toKey: kPackageDumpKey), workingDirectory: inputFolder),
            AdHocAction { context in
                guard
                    let dump: PackageDump = context.get(for: kPackageDumpKey),
                    dump.products.contains(where: { $0.name == productName })
                else {
                    return .failure(PackageBuilderErrors.noSuchProductDefinition)
                }
                return .success(())
            },
            SPMAction(
                job: .gatherBinPath(
                    product: productName,
                    configuration: kReleaseConfiguration,
                    toKey: kBinPathKey
                ),
                workingDirectory: inputFolder
            ),
            SPMAction(
                job: .build(
                    product: productName,
                    configuration: kReleaseConfiguration
                ),
                workingDirectory: inputFolder
            ),
            AdHocAction { context in
                guard let binPath: String = context.get(for: kBinPathKey) else {
                    return .failure(PackageBuilderErrors.binaryProductMissing)
                }
                let rs = try FileManager.default.contentsOfDirectory(atPath: binPath)
                    .filter { $0.hasSuffix(".dylib") && $0.contains(productName) }

                guard let binName = rs.first else {
                    return .failure(PackageBuilderErrors.binaryProductMissing)
                }

                context.put(
                    for: kFlowPluginKey,
                    option: StringOption(defaultValue: [binPath, binName].joined(separator: "/"))
                )
                return .success(())
            }
        ]
    }

    private let productName: String
    private let inputFolder: String

    init(productName: String, inputFolder: String) {
        self.productName = productName
        self.inputFolder = inputFolder
    }
}

private let kReleaseConfiguration = "release"
private let kPackageDumpKey = "package_dump"
private let kBinPathKey = "bin_path"
private let kFlowPluginKey = "flow_plugin"
