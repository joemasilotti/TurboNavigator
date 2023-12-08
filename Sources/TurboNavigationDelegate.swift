import SafariServices
import Turbo
import WebKit

/// Implement to be notified when certain navigations are performed
/// or to render a native controller instead of a Turbo web visit.
public protocol TurboNavigationDelegate: AnyObject {
    typealias RetryBlock = () -> Void

    /// Respond to authentication challenge presented by web servers behing basic auth.
    func didReceiveAuthenticationChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)

    /// Accept or reject a visit proposal.
    ///
    /// There are three `ProposalResult` cases:
    ///    - term `accept`: Proposals are accepted and a new `VisitableViewController` is displayed.
    ///    - term `acceptCustom(UIViewController)`: You may provide a view controller to be displayed, otherwise a new `VisitableViewController` is displayed.
    ///    - term `reject`: No changes to navigation occur.
    ///
    /// - Parameter proposal: `VisitProposal` navigation destination
    /// - Returns:`ProposalResult` - how to react to the visit proposal
    /// - Note: optional
    func handle(proposal: VisitProposal) -> ProposalResult

    /// An error occurred loading the request, present it to the user.
    /// Retry the request by executing the closure.
    /// If not implemented, will present the error's localized description and a Retry button.
    /// - Note: optional
    func visitableDidFailRequest(_ visitable: Visitable, error: Error, retry: @escaping RetryBlock)

    /// Implement to customize handling of external URLs.
    /// If not implemented, will present `SFSafariViewController` as a modal and load the URL.
    /// - Note: optional
    func openExternalURL(_ url: URL, from controller: UIViewController)

    /// Implement to become the web view's navigation delegate after the initial cold boot visit is completed.
    /// https://github.com/hotwired/turbo-ios/blob/main/Docs/Overview.md#becoming-the-web-views-navigation-delegate
    /// - Note: optional
    func sessionDidLoadWebView(_ session: Session)

    /// Useful for interacting with the web view after the page loads.
    /// - Note: optional
    func sessionDidFinishRequest(_ session: Session)
}

public extension TurboNavigationDelegate {
    func handle(proposal: VisitProposal) -> ProposalResult { .accept }

    func visitableDidFailRequest(_ visitable: Visitable, error: Error, retry: @escaping RetryBlock) {
        if let errorPresenter = visitable as? ErrorPresenter {
            errorPresenter.presentError(error) {
                retry()
            }
        }
    }

    func openExternalURL(_ url: URL, from controller: UIViewController) {
        if ["http", "https"].contains(url.scheme) {
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.modalPresentationStyle = .pageSheet
            if #available(iOS 15.0, *) {
                safariViewController.preferredControlTintColor = .tintColor
            }
            controller.present(safariViewController, animated: true)
        } else if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    func didReceiveAuthenticationChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }

    func sessionDidFinishRequest(_ session: Session) {}

    func sessionDidLoadWebView(_ session: Session) {}
}
