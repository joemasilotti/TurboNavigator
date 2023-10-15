import SafariServices
import Turbo
import WebKit

/// Implement to be notified when certain navigations are performed
/// or to render a native controller instead of a Turbo web visit.
public protocol TurboNavigationDelegate: AnyObject {
    typealias RetryBlock = () -> Void

    /// Respond to authentication challenge presented by web servers behing basic auth.
    func didReceiveAuthenticationChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)

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

    /// Optional. Implement to customize handling of external URLs.
    /// If not implemented, will present `SFSafariViewController` as a modal and load the URL.
    func openExternalURL(_ url: URL, from controller: UIViewController)

    /// Optional. Implement to become the web view's navigation delegate after the initial cold boot visit is completed.
    /// https://github.com/hotwired/turbo-ios/blob/main/Docs/Overview.md#becoming-the-web-views-navigation-delegate
    func sessionDidLoadWebView(_ session: Session)

    /// Optional. Useful for interacting with the web view after the page loads.
    func sessionDidFinishRequest(_ session: Session)

    /// Optional. Override to customize the behavior when a JavaScript `alert()` dialog is shown.
    func controller(_ controller: UIViewController, runJavaScriptAlertPanelWithMessage message: String, completionHandler: @escaping () -> Void)

    /// Optional. Override to customize the behavior when a JavaScript `confirm()` dialog is shown.
    func controller(_ controller: UIViewController, runJavaScriptConfirmPanelWithMessage message: String, completionHandler: @escaping (Bool) -> Void)
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

    func sessionDidFinishRequest(_ session: Session) {}

    func sessionDidLoadWebView(_ session: Session) {}

    func controller(_ controller: UIViewController, runJavaScriptAlertPanelWithMessage message: String, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default) { _ in
            completionHandler()
        })
        controller.present(alert, animated: true)
    }

    func controller(_ controller: UIViewController, runJavaScriptConfirmPanelWithMessage message: String, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive) { _ in
            completionHandler(true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        controller.present(alert, animated: true)
    }
}
