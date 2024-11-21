import ArgumentParser

@main
struct Swuild: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Utility to execute actions, aka CI scripts executor, built with Swift",
        subcommands: [
            Dummy.self,
            Edit.self,
            Run.self,
        ],
        defaultSubcommand: Dummy.self
    )
}
