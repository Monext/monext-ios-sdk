//
//  plugin.swift
//  Monext
//
//  Created by lucas bianciotto  on 26/02/2026.
//

import PackagePlugin
import Foundation

@main
struct InjectSecretsPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        let outputFileURL = context.pluginWorkDirectoryURL.appending(path: "APIConfig.swift")

        return [.buildCommand(
            displayName: "Inject API Secrets",
            executable: try context.tool(named: "InjectSecretsExecutable").url,
            arguments: [outputFileURL.path(percentEncoded: false)],
            outputFiles: [outputFileURL]
        )]
    }
}
