//  Created by Denis Malykh on 19.11.2024.

import Foundation

public enum FlowErrors: Error {
    case actionExecution(cause: Error)
}

/// Structure to hold timing information for execution tracking
public struct ActionExecutionTiming {
    public let actionName: String
    public let actionHint: String
    public let executionTime: TimeInterval

    public init(actionName: String, actionHint: String, executionTime: TimeInterval) {
        self.actionName = actionName
        self.actionHint = actionHint
        self.executionTime = executionTime
    }
}

/// Structure to hold timing summary for a flow execution
public struct FlowExecutionSummary {
    public let flowName: String
    public let platform: Platform
    public let actionTimings: [ActionExecutionTiming]
    public let totalFlowTime: TimeInterval

    public init(
        flowName: String,
        platform: Platform,
        actionTimings: [ActionExecutionTiming],
        totalFlowTime: TimeInterval
    ) {
        self.flowName = flowName
        self.platform = platform
        self.actionTimings = actionTimings
        self.totalFlowTime = totalFlowTime
    }
}

public protocol Flow {
    var name: String { get }
    var platforms: [Platform] { get }
    var description: String { get }

    func actions(for context: Context, and platform: Platform) throws -> [any Action]

    /// Execute the flow with the given context on a specific platform
    /// - Parameters:
    ///   - context: The context in which to execute the flow
    ///   - platform: The platform on which to execute the flow
    /// - Returns: A summary of the flow execution including timing information
    func execute(context: Context, platform: Platform) async throws -> FlowExecutionSummary

    /// Execute the flow with the given context on all supported platforms
    /// - Parameter context: The context in which to execute the flow
    /// - Returns: An array of summaries for each platform execution
    func execute(context: Context) async throws -> [FlowExecutionSummary]
}

public extension Action {
    func canExecute(context: Context, platform: Platform) -> Bool {
        if let key = mutualExclusivityKey {
            if context.isMutualExclusivityKeyExecuted(key) {
                print("❗️ Skipping \(Self.name) action [\(hint)] due to mutual exclusivity key '\(key)' already executed")
                return false
            }
            context.addExecutedMutualExclusivityKey(key)
        }

        return true
    }
}

public extension Flow {
    func execute(context: Context, platform: Platform) async throws -> FlowExecutionSummary {
        let actions = try actions(for: context, and: platform)
        var actionTimings: [ActionExecutionTiming] = []

        let flowStartTime = CFAbsoluteTimeGetCurrent()

        for action in actions {
            guard action.canExecute(context: context, platform: platform) else {
                continue
            }

            print("⚡️ Executing \(type(of: action).name) action [\(action.hint)]...")
            guard type(of: action).isSupported(for: platform) else {
                print("❗️ Action \(type(of: action).name) is not supported for \(platform), skipping!")
                continue
            }

            let startTime = CFAbsoluteTimeGetCurrent()
            try await action.execute(context: context, platform: platform)
            let endTime = CFAbsoluteTimeGetCurrent()
            let executionTime = endTime - startTime

            let timing = ActionExecutionTiming(actionName: type(of: action).name, actionHint: action.hint, executionTime: executionTime)
            actionTimings.append(timing)

            if let flowAction = action as? FlowExecutionSummaryProvider,
               let nestedSummary = flowAction.flowExecutionSummary {
                actionTimings.append(contentsOf: nestedSummary.actionTimings)
            }
        }

        let flowEndTime = CFAbsoluteTimeGetCurrent()
        let totalFlowTime = flowEndTime - flowStartTime

        return FlowExecutionSummary(flowName: self.name, platform: platform, actionTimings: actionTimings, totalFlowTime: totalFlowTime)
    }

    func execute(context: Context) async throws -> [FlowExecutionSummary] {
        print("⚡️ Executing \(name) flow...")
        var summaries: [FlowExecutionSummary] = []

        for platform in platforms {
            print("⚡️ Executing \(name) flow on platform \(platform)...")
            let summary = try await execute(context: context, platform: platform)
            summaries.append(summary)
        }

        return summaries
    }
}

/// Extension on array of FlowExecutionSummary to provide utility functions for displaying execution summaries
public extension Array where Element == FlowExecutionSummary {
    /// Display the execution summary table after successful flow completion
    func displayExecutionSummary() {
        guard !self.isEmpty else { return }

        var maxActionNameLength = 6 // Minimum width for "Action"
        var maxHintLength = 4 // Minimum width for "Hint"

        for summary in self {
            for timing in summary.actionTimings {
                maxActionNameLength = Swift.max(maxActionNameLength, timing.actionName.count)
                maxHintLength = Swift.max(maxHintLength, timing.actionHint.count)
            }
        }

        maxActionNameLength = Swift.max(maxActionNameLength, 6) // "Action"
        maxHintLength = Swift.max(maxHintLength, 4) // "Hint"

        let stepColumnWidth = 4  // "Step"
        let actionColumnWidth = maxActionNameLength  // Action name
        let hintColumnWidth = maxHintLength  // Hint
        let timeColumnWidth = 14  // "Time (in s)" - increased width to prevent overflow

        let totalWidth = 2 + stepColumnWidth + 3 + actionColumnWidth + 3 + hintColumnWidth + 3 + timeColumnWidth + 2

        func pad(string: String, toWidth: Int) -> String {
            let padding = toWidth - string.count
            if padding <= 0 {
                return string
            }
            return string + String(repeating: " ", count: padding)
        }

        func center(string: String, inWidth: Int) -> String {
            let padding = inWidth - string.count
            if padding <= 0 {
                return string
            }
            let leftPadding = padding / 2
            let rightPadding = padding - leftPadding
            return String(repeating: " ", count: leftPadding) + string + String(repeating: " ", count: rightPadding)
        }

        let separator = "+" + String(repeating: "-", count: stepColumnWidth + 2) + "+" +
                              String(repeating: "-", count: actionColumnWidth + 2) + "+" +
                              String(repeating: "-", count: hintColumnWidth + 2) + "+" +
                              String(repeating: "-", count: timeColumnWidth + 2) + "+"

        print("")
        print(separator)
        print("|" + center(string: "Execution summary", inWidth: totalWidth - 2) + "|")
        print(separator)
        print(
            "| " +
            pad(string: "Step", toWidth: stepColumnWidth) +
            " | " +
            pad(string: "Action", toWidth: actionColumnWidth) +
            " | " +
            pad(string: "Hint", toWidth: hintColumnWidth) +
            " | " +
            pad(string: "Time (in s)", toWidth: timeColumnWidth) +
            " |"
        )
        print(separator)

        var totalTime: TimeInterval = 0

        for summary in self {
            let platformString = "Platform: \(summary.platform.description)"
            print(separator)
            print("| " + center(string: platformString, inWidth: totalWidth - 4) + " |")
            print(separator)

            for (index, timing) in summary.actionTimings.enumerated() {
                let step = String(index)
                let actionName = timing.actionName
                let hint = timing.actionHint
                let timeFormatted = String(format: "%.2f", timing.executionTime)

                let line = "| " +
                    pad(string: step, toWidth: stepColumnWidth) + " | " +
                    pad(string: actionName, toWidth: actionColumnWidth) + " | " +
                    pad(string: hint, toWidth: hintColumnWidth) + " | " +
                    pad(string: timeFormatted, toWidth: timeColumnWidth) + " |"
                print(line)
            }

            totalTime += summary.totalFlowTime
        }

        print(separator)
        print("")

        if totalTime >= 60 {
            let timeSavedMinutes = Int(totalTime / 60)
            print("swuild saved you \(timeSavedMinutes) minutes 🎉")
        } else {
            let timeFormatted = String(format: "%.2f", totalTime)
            print("swuild saved you \(timeFormatted) seconds 🎉")
        }
    }
}
