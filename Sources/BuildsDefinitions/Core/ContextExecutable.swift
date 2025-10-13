//  Created by Denis Malykh on 05.04.2025.

public protocol ContextExecutable {
    func execute(context: Context, platform: Platform) async throws
}
