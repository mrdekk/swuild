//  Created by Denis Malykh on 19.11.2024.

import BuildsDefinitions
import Foundation
import ArgumentParser
import XcodeProj

struct Edit: AsyncParsableCommand {
    mutating func run() async throws {
        let proj = PBXProj()

        // basic setup

        let mainGroup = PBXGroup(sourceTree: .group, path: "/Users/mrdekk/Downloads")
        proj.add(object: mainGroup)
        let productsGroup = PBXGroup(children: [], sourceTree: .group, name: "Products")
        proj.add(object: productsGroup)
        let sourcesGroup = PBXGroup(children: [], sourceTree: .group, name: "Manifests")
        proj.add(object: sourcesGroup)

        mainGroup.children.append(sourcesGroup)
        mainGroup.children.append(productsGroup)

        let configurationList = XCConfigurationList()
        proj.add(object: configurationList)
        let configurations = try configurationList.addDefaultConfigurations()

        let project = PBXProject(
            name: "Manifests",
            buildConfigurationList: configurationList,
            compatibilityVersion: Xcode.Default.compatibilityVersion,
            preferredProjectObjectVersion: nil,
            minimizedProjectReferenceProxies: nil,
            mainGroup: mainGroup,
            productsGroup: productsGroup
        )
        proj.add(object: project)
        proj.rootObject = project

        // target setup

        let sourcesBuildPhase = PBXSourcesBuildPhase()
        proj.add(object: sourcesBuildPhase)
        let resourcesBuildPhase = PBXResourcesBuildPhase()
        proj.add(object: PBXResourcesBuildPhase())

        let productType = PBXProductType.framework
        let productName = "Test.\(productType.fileExtension!)"
        let productReference = PBXFileReference(sourceTree: .buildProductsDir, name: productName)
        proj.add(object: productReference)
        productsGroup.children.append(productReference)

        let target = PBXNativeTarget(
            name: "Test",
            buildConfigurationList: configurationList,
            buildPhases: [sourcesBuildPhase, resourcesBuildPhase],
            productName: productName,
            product: productReference,
            productType: productType
        )
        proj.add(object: target)
        project.targets.append(target)

        let ref = try sourcesGroup.addFile(at: "/Users/mrdekk/Downloads/test.swift", sourceRoot: .current)

        var pbxBuildFiles = [PBXBuildFile]()
        let pbxBuildFile = PBXBuildFile(file: ref, settings: nil)
        pbxBuildFiles.append(pbxBuildFile)

        pbxBuildFiles.forEach { proj.add(object: $0) }
        sourcesBuildPhase.files = pbxBuildFiles

        configurations.forEach {
            $0.buildSettings["GENERATE_INFOPLIST_FILE"] = "YES"
            $0.buildSettings["SWIFT_VERSION"] = "5.0"
            $0.buildSettings["PRODUCT_MODULE_NAME"] = "Test"
            $0.buildSettings["PRODUCT_NAME"] = "Test"
        }

        // writing

        let workspaceData = XCWorkspaceData(children: [])
        let workspace = XCWorkspace(data: workspaceData)

        let xcodeproj = XcodeProj(workspace: workspace, pbxproj: proj)
        try xcodeproj.write(path: "/Users/mrdekk/Downloads/Manifests.xcodeproj")
    }
}
