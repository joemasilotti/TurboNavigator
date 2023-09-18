import Foundation
import Turbo

public protocol TurboNavigatingCoordinatorDelegate : AnyObject {
    
    /// Allows a requested `VisitProposal` to be routed to another `TurboNavigator`.
    ///
    /// - Parameters:
    ///   - proposal: the proposal to be rerouted
    ///   - navigator: the navigator that is proposing the visit
    ///   - coordinator: the coordinator handling all navigators
    /// - Returns: whether the proposal is followed by `navigator` or routed elsewhere
    func reroute(proposal: VisitProposal,
                 from navigator: TurboNavigator,
                 coordinator: TurboNavigatingCoordinator) -> VisitProposalRoute
}

/// Return from `reroute(proposal:from:coordinator:)` to reroute `VisitProposal`, if needed.
public enum VisitProposalRoute {
    case follow(ProposalResult)
    case reroute(TurboNavigator)
}
