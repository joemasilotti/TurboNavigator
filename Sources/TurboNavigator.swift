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

public class TurboNavigator: TurboNavigationHierarchyControllerDelegate {
    
    public weak var delegate: TurboNavigatorDelegate?
    
    public var rootViewController: UINavigationController { hierarchyController.navigationController }
    
    public var webkitUIDelegate: TurboWKUIController? {
        didSet {
            session.webView.uiDelegate = webkitUIDelegate
            modalSession.webView.uiDelegate = webkitUIDelegate
        }
    }
    
    public init(session: Session,
                modalSession: Session,
                delegate: TurboNavigatorDelegate? = nil) {
        self.session = session
        self.modalSession = modalSession
        self.delegate = delegate
        
        self.session.delegate = self
        self.modalSession.delegate = self
    }
    
    /// Transforms `URL` -> `VisitProposal` -> `UIViewController`.
    /// Given the `VisitProposal`'s properties, push or present this view controller.
    ///
    /// - Parameter url: the URL to visit.
    public func route(url: URL) {
        let options = VisitOptions(action: .advance, response: nil)
        let properties = session.pathConfiguration?.properties(for: url) ?? PathProperties()
        let proposal = VisitProposal(url: url, options: options, properties: properties)
        
        guard let controller = controller(for: proposal) else { return }
        
        hierarchyController.route(controller: controller, proposal: proposal)
    }
    
    let session: Session
    let modalSession: Session
    
    /// Modifies a UINavigationController according to visit proposals.
    lazy var hierarchyController = TurboNavigationHierarchyController(delegate: self)
    
    private func controller(for proposal: VisitProposal) -> UIViewController? {
        
        guard let delegate else {
            return VisitableViewController(url: proposal.url)
        }
        
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
        // Do we need to expose this if we save cookies?
    }

    public func sessionDidLoadWebView(_ session: Session) {
        session.webView.navigationDelegate = session
        // Do we need to expose this?
    }
}

// MARK: TurboNavigationHierarchyControllerDelegate
extension TurboNavigator {
    
    func visit(_ controller: Visitable, 
               on: TurboNavigationHierarchyController.NavigationStackType,
               with: Turbo.VisitOptions) {
        switch on {
        case .main:
            session.visit(controller, action: .advance)
        case .modal:
            session.visit(controller, action: .advance)
        }
    }
    
    func refresh(navigationStack: TurboNavigationHierarchyController.NavigationStackType) {
        switch navigationStack {
        case .main: session.reload()
        case .modal: session.reload()
        }
    }
}
