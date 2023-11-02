//
//  File 2.swift
//  
//
//  Created by Fernando Olivares on 01/11/23.
//

import Foundation
import UIKit
import Turbo
import SafariServices

protocol TurboNavigatorDelegate : AnyObject {
    typealias RetryBlock = () -> Void
    
    /// Optional. Accept or reject a visit proposal.
    /// If accepted, you may provide a view controller to be displayed, otherwise a new `VisitableViewController` is displayed.
    /// If rejected, no changes to navigation occur.
    /// If not implemented, proposals are accepted and a new `VisitableViewController` is displayed.
    ///
    /// - Parameter proposal: navigation destination
    /// - Returns: how to react to the visit proposal
    func handle(proposal: VisitProposal) -> ProposalResult
    
    /// Optional. An error occurred loading the request, present it to the user.
    /// Retry the request by executing the closure.
    /// If not implemented, will present the error's localized description and a Retry button.
    func visitableDidFailRequest(_ visitable: Visitable, error: Error, retry: @escaping RetryBlock)
    
    /// Respond to authentication challenge presented by web servers behing basic auth.
    func didReceiveAuthenticationChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}

class TurboNavigator {
    
    let session: Session
    let modalSession: Session
    let hierarchyController: TurboNavigationHierarchyController
    
    weak var delegate: TurboNavigatorDelegate?
    
    init(session: Session, modalSession: Session) {
        self.session = session
        self.modalSession = modalSession
        self.hierarchyController = TurboNavigationHierarchyController()
    }
    
    func route(url: URL) {
        let options = VisitOptions(action: .advance, response: nil)
        let properties = session.pathConfiguration?.properties(for: url) ?? PathProperties()
        let proposal = VisitProposal(url: url, options: options, properties: properties)
        let controller = controller(for: proposal)
        
        guard let controller else { return }
        
        hierarchyController.route(controller: controller, proposal: proposal)
    }
    
    private func controller(for proposal: VisitProposal) -> UIViewController? {
        
        guard let delegate else { return nil }
        
        switch delegate.handle(proposal: proposal) {
        case .accept:
            return VisitableViewController(url: proposal.url)
        case .acceptCustom(let customViewController):
            return customViewController
        case .reject:
            return nil
        }
    }
}

// MARK: - SessionDelegate

extension TurboNavigator: SessionDelegate {
    
    public func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        
        guard let controller = controller(for: proposal) else { return }
        
        hierarchyController.route(controller: controller,
                                  proposal: proposal)
    }

    public func sessionDidFinishFormSubmission(_ session: Session) {
        if session == modalSession {
            self.session.clearSnapshotCache()
        }
    }

    public func session(_ session: Session, openExternalURL url: URL) {
        let navigationType: TurboNavigationHierarchyController.NavigationStackType = session === modalSession ? .modal : .main
        hierarchyController.openExternal(url: url, navigationType: navigationType)
    }

    public func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        delegate?.visitableDidFailRequest(visitable, error: error) {
            session.reload()
        }
    }

    public func sessionWebViewProcessDidTerminate(_ session: Session) {
        session.reload()
    }

    public func session(_ session: Session, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        delegate?.didReceiveAuthenticationChallenge(challenge, completionHandler: completionHandler)
    }

    public func sessionDidFinishRequest(_ session: Session) {
        // Handle cookies. Do we need to expose this?
    }

    public func sessionDidLoadWebView(_ session: Session) {
        session.webView.navigationDelegate = session
        // Do we need to expose this?
        // delegate.sessionDidLoadWebView(session)
    }
}
