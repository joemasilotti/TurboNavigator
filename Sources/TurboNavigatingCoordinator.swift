import UIKit
import Turbo
import SafariServices

public class TurboNavigatingCoordinator : TurboNavigationDelegate {
    
}

public extension TurboNavigatingCoordinator {
    
    func handle(proposal: VisitProposal) -> ProposalResult { .accept }

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
