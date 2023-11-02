import SafariServices
import Turbo
import WebKit

/// Implement to be notified when certain navigations are performed
/// or to render a native controller instead of a Turbo web visit.
public protocol TurboNavigationDelegate: AnyObject {
    /// Optional. Override to provide a custom implementation of `WKUIDelegate`, like handling JavaScript alerts.
    var webViewDelegate: WKUIDelegate? { get }

    /// Optional. Accept or reject a visit proposal.
    /// If accepted, you may provide a view controller to be displayed, otherwise a new `VisitableViewController` is displayed.
    /// If rejected, no changes to navigation occur.
    /// If not implemented, proposals are accepted and a new `VisitableViewController` is displayed.
    ///
    /// - Parameter proposal: navigation destination
    /// - Returns: how to react to the visit proposal
    func handle(proposal: VisitProposal) -> ProposalResult
    
    /// Optional. Override to customize the web views, for example to configure Strada.
    /// - Parameter configuration: Configured with a shared `WKProcessPool` and Turbo Native user agent.
    /// - Returns: The web view used to create each `Session` by `TurboNavigator`.
    func webView(configuration: WKWebViewConfiguration) -> WKWebView

    // MARK: - SessionDelegate overrides

    /// Optional. Implement these functions when via an extension.

    func session(_ session: Session, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    func sessionDidLoadWebView(_ session: Session)

    func sessionDidStartRequest(_ session: Session)
    func sessionDidFinishRequest(_ session: Session)
    func sessionDidStartFormSubmission(_ session: Session)
}

public extension TurboNavigationDelegate {
    var webViewDelegate: WKUIDelegate? { nil }

    func handle(proposal: VisitProposal) -> ProposalResult { .accept }

    func webView(configuration: WKWebViewConfiguration) -> WKWebView {
        return WKWebView(frame: .zero, configuration: configuration)
    }

    // MARK: - SessionDelegate

    func session(_ session: Session, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }

    func sessionDidLoadWebView(_ session: Session) {}

    func sessionDidStartRequest(_ session: Session) {}
    func sessionDidFinishRequest(_ session: Session) {}
    func sessionDidStartFormSubmission(_ session: Session) {}
}
