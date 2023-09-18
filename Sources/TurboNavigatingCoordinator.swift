import UIKit
import Turbo
import SafariServices

/// Allows communication between different `TurboNavigator`s.
public class TurboNavigatingCoordinator : TurboNavigationDelegate {
    
    public private(set) var navigators: [TurboNavigator]
    
    /// Convenience: Returns the first navigator.
    public var rootNavigator: TurboNavigator { navigators.first! }
    
    public weak var delegate: TurboNavigatingCoordinatorDelegate?
    
    /// After initialization, `navigators` will always have at least 1 `TurboNavigator`.
    ///
    /// - Parameter rootNavigator: the first navigator, if given
    public init(rootNavigator: TurboNavigator? = nil) {
        navigators = []
        
        if let rootNavigator {
            navigators.append(rootNavigator)
        } else {
            navigators.append(TurboNavigator(delegate: self))
        }
    }
    
    public func replaceRootNavigator(with newRootNavigator: TurboNavigator) {
        navigators[0] = newRootNavigator
    }
}

// MARK: TurboNavigationDelegate
public extension TurboNavigatingCoordinator {
    
    func handle(proposal: VisitProposal, navigator: TurboNavigator) -> ProposalResult {
        
        guard let delegate else { return .accept }
        
        switch delegate.reroute(proposal: proposal,
                                from: navigator,
                                coordinator: self) {
            
        case .follow(let result):
            return result
            
        case .reroute(let newNavigator):
            newNavigator.route(proposal)
            return .reject
        }
    }

    func visitableDidFailRequest(_ visitable: Visitable, error: Error, retry: @escaping RetryBlock) {
        if let errorPresenter = visitable as? ErrorPresenter {
            errorPresenter.presentError(error) {
                retry()
            }
        }
    }

    func openExternalURL(_ url: URL, from controller: UIViewController) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            safariViewController.preferredControlTintColor = .tintColor
        }
        controller.present(safariViewController, animated: true)
    }

    func didReceiveAuthenticationChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }

    func sessionDidLoadWebView(_ session: Session) {}
}
