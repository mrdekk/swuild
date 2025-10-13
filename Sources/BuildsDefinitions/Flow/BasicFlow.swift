//  Created by Denis Malykh on 03.10.2025.

public struct BasicFlow: Flow {
    public let name: String
    public let platforms: [Platform]
    public let description: String
    private let actionsBuilder: (Context, Platform) throws -> [any Action]

    public func actions(for context: Context, and platform: Platform) throws -> [any Action] {
        return try actionsBuilder(context, platform)
    }

    public init(
        name: String,
        platforms: [Platform],
        description: String,
        @FlowActionsBuilder actions: @escaping (Context, Platform) throws -> [any Action]
    ) {
        self.name = name
        self.platforms = platforms
        self.description = description
        self.actionsBuilder = actions
    }
}
