//  Created by Denis Malykh on 19.11.2024.

import Foundation
import BuildsDefinitions

public struct EchoAction: Action {
    public static let name = "echo"

    public static let description = "Simple echo action for tests"

    public static let authors = Author.defaultAuthors

    public static func isSupported(for platform: Platform) -> Bool {
        true
    }

    public func execute(context: Context) async throws -> Result<Void, Error> {
        print("OHCE")
        return .success(())
    }
}
