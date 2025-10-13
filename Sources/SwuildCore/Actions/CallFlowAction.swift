//  Created by Denis Malykh on 11.10.2025.

import Foundation
import BuildsDefinitions

public struct CallFlowAction: Action {
    public static let name = "call-flow"
    public static let description = "Executes another flow"
    public static let authors = Author.defaultAuthors
    
    private let flow: any Flow
    
    public init(flow: any Flow) {
        self.flow = flow
    }
    
    public static func isSupported(for platform: Platform) -> Bool {
        true
    }
    
    public func execute(context: Context, platform: Platform) async throws {
        try await flow.execute(context: context, platform: platform)
    }
}
