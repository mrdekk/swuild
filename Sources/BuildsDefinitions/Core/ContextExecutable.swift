//  Created by Denis Malykh on 05.04.2025.

public protocol ContextExecutable {
    func execute(context: Context) async throws -> Result<Void, Error>
}
