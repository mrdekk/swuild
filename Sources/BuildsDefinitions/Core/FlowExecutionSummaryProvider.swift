//  Created by Denis Malykh on 11.10.2025.

import Foundation

///  This protocol is used to provide access to flow execution summary information
///  for actions that execute flows.
public protocol FlowExecutionSummaryProvider {
    var flowExecutionSummary: FlowExecutionSummary? { get }
}
