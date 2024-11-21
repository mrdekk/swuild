//  Created by Denis Malykh on 19.11.2024.

import ArgumentParser
import BuildsDefinitions
import Foundation
import SwuildCore

struct Dummy: AsyncParsableCommand {
    mutating func run() async throws {
        struct ShAction: Action {
            static let name = "sh"

            static let description = "Shell action for tests"

            static let authors = Author.defaultAuthors

            static func isSupported(for platform: BuildsDefinitions.Platform) -> Bool {
                true
            }

            func execute(context: Context) async throws -> Result<Void, Error> {
                .success(())
            }
        }

        struct OurFlow: Flow {
            let name = "our_flow"

            let platforms: [Platform] = [.iOS(version: .any)]

            let description = "Our flow"

            let actions: [any Action] = [
                ShAction()
            ]
        }

        let flow = OurFlow()
        do {
            let context = makeContext()
            let result = try await flow.execute(context: context)
            print("\(result)")
        } catch {

        }
    }
}
