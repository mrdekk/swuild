//  Created by Denis Malykh on 19.11.2024.

import Foundation

public protocol Action {
    static var name: String { get }
    static var description: String { get }
    static var authors: [Author] { get }

    static func isSupported(for platform: Platform) -> Bool
    
    func execute(context: Context) async throws -> Result<Void, Error>
}
