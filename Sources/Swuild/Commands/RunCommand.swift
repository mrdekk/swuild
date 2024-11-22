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
            let buildContext = makeContext()
            let buildFlow = RunFlow(productName: flowName, inputFolder: inputFolder)
            let buildResult = try await buildFlow.execute(context: buildContext)
            guard
                case .success = buildResult,
                let flowPlugingPath: String = buildContext.get(for: kFlowPluginKey)
            else {
                throw PackageBuilderErrors.genericBuildError(message: "build flow execution failure")
            }

            let plugin = Plugin(path: flowPlugingPath)
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

private let kReleaseConfiguration = "release"
private let kPackageDumpKey = "package_dump"
private let kBinPathKey = "bin_path"
private let kFlowPluginKey = "flow_plugin"
