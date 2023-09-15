import UIKit
import Turbo
import SafariServices

public class TurboNavigatingCoordinator : TurboNavigationDelegate {
    
    public private(set) var navigators: [TurboNavigator]
    
    public var rootNavigator: TurboNavigator { navigators.first! }
    
    weak var delegate: TurboNavigatingCoordinatorDelegate?
    
    public init() {
        navigators = []
        navigators.append(TurboNavigator(delegate: self))
    }
}

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
