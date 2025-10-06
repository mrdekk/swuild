//  Created by Denis Malykh on 03.10.2025.

public struct BasicFlow: Flow {
    public let name: String
    public let platforms: [Platform]
    public let description: String
    private let _actions: [any Action]

    public var actions: [any Action] {
        return _actions
    }

    public init(
        name: String,
        platforms: [Platform],
        description: String,
        @FlowActionsBuilder actions: () -> [any Action]
    ) {
        self.name = name
        self.platforms = platforms
        self.description = description
        self._actions = actions()
    }
}
