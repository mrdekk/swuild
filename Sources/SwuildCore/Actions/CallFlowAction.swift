//  Created by Denis Malykh on 11.10.2025.

import Foundation
import BuildsDefinitions

public final class CallFlowAction: Action, FlowExecutionSummaryProvider {
    public static let name = "call-flow"
    public static let description = "Executes another flow"
    public static let authors = Author.defaultAuthors

    public let hint: String
    public let measurementKeys: [String]?

    public private(set) var flowExecutionSummary: FlowExecutionSummary?

    private let flow: any Flow

    public init(hint: String = "-", measurementKeys: [String]? = nil, flow: any Flow) {
        self.hint = hint
        self.measurementKeys = measurementKeys
        self.flow = flow
    }

    public static func isSupported(for platform: Platform) -> Bool {
        true
    }

    public func execute(context: Context, platform: Platform) async throws {
        let startTime = Date().timeIntervalSince1970
        let monotonicStartTime = CFAbsoluteTimeGetCurrent()

        self.flowExecutionSummary = try await flow.execute(context: context, platform: platform)

        let monotonicEndTime = CFAbsoluteTimeGetCurrent()
        let executionTime = monotonicEndTime - monotonicStartTime

        if let keys = measurementKeys {
            context.addMeasurement(
                .init(
                    contextData: context.extractContextData(for: keys),
                    startTime: startTime,
                    executionTime: executionTime,
                    hint: hint
                ),
                withKey: hint
            )
        }
    }
}
