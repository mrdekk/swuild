//  Created by Denis Malykh on 19.11.2024.

import Foundation

public struct Author {
    public let name: String
    public let email: String

    public static func make(name: String, email: String) -> Author {
        Author(name: name, email: email)
    }

    public static let defaultAuthors = [
        make(name: "Swuild Authors", email: "null@example.com"), // TODO: proper email
    ]
}
