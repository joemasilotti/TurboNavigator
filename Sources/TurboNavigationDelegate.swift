import SafariServices
import Turbo
import WebKit

/// Implement to be notified when certain navigations are performed
/// or to render a native controller instead of a Turbo web visit.
public protocol TurboNavigationDelegate: AnyObject {
    /// An error occurred loading the request, present it to the user.
    /// Retry the request by calling `session.reload()`.
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error)

    /// Respond to authentication challenge presented by web servers behing basic auth.
    func didReceiveAuthenticationChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)

    /// Optional. Implement to override or customize the controller to be displayed.
    /// Return `nil` to not display or route anything.
    func controller(_ controller: VisitableViewController, forProposal proposal: VisitProposal) -> UIViewController?

    /// Optional. Implement to customize handling of external URLs.
    /// If not implemented, will present `SFSafariViewController` as a modal and load the URL.
    func openExternalURL(_ url: URL, from controller: UIViewController)

    /// Optional. Implement to handle when the web view process dies and can't be restored.
    func sessionWebViewProcessDidTerminate(_ session: Session)

    /// Optional. Implement if you need to change the naviagation delegate on the webView (https://github.com/hotwired/turbo-ios/blob/main/Docs/Overview.md#becoming-the-web-views-navigation-delegate)
    func sessionDidLoadWebView(_ session: Session)
}

public extension TurboNavigationDelegate {
    func controller(_ controller: VisitableViewController, forProposal proposal: VisitProposal) -> UIViewController? {
        VisitableViewController(url: proposal.url)
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

    func sessionWebViewProcessDidTerminate(_ session: Session) {}
}
