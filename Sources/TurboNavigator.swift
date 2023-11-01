import SafariServices
import Turbo
import UIKit
import WebKit

/// Handles navigation to new URLs using the following rules:
/// https://github.com/joemasilotti/TurboNavigator#handled-flows
open class TurboNavigator: NSObject, SessionDelegate, WKUIDelegate {
    /// Default initializer.
    /// - Parameters:
    ///   - pathConfiguration: Optional. Remotely configure settings and path rules.
    ///   - navigationController: Optional. Override the main navigation stack.
    ///   - modalNavigationController: Optional. Override the modal navigation stack.
    public init(
        pathConfiguration: PathConfiguration? = nil,
        navigationController: UINavigationController = UINavigationController(),
        modalNavigationController: UINavigationController = UINavigationController())
    {
        self.pathConfiguration = pathConfiguration
        self.navigationController = navigationController
        self.modalNavigationController = modalNavigationController
        super.init()
    }

    /// `navigationController` or `modalNavigationController`, whichever is being shown.
    public var currentNavigationController: UINavigationController {
        navigationController.presentedViewController != nil ? modalNavigationController : navigationController
    }

    /// Modal view controller otherwise top view controller on the current navigation stack.
    public var visibleViewController: UIViewController? {
        currentNavigationController.visibleViewController
    }

    /// Accept or reject a visit proposal.
    /// If accepted, you may provide a view controller to be displayed, otherwise a new `VisitableViewController` is displayed.
    /// If rejected, no changes to navigation occur.
    /// If not overridden, proposals are accepted and a new `VisitableViewController` is displayed.
    ///
    /// - Parameter proposal: navigation destination
    /// - Returns: how to react to the visit proposal
    open func handle(proposal: VisitProposal) -> ProposalResult {
        .accept
    }

    /// Follows rules from `pathConfiguration` to route a `URL` to the stack.
    public func route(_ url: URL) {
        let options = VisitOptions(action: .advance, response: nil)
        let properties = session.pathConfiguration?.properties(for: url) ?? PathProperties()
        let proposal = VisitProposal(url: url, options: options, properties: properties)
        route(proposal)
    }

    /// Follows rules from `pathConfiguration` to route a `VisitProposal` to the stack.
    public func route(_ proposal: VisitProposal) {
        guard let controller = controller(for: proposal) else { return }

        if let alert = controller as? UIAlertController {
            presentAlert(alert)
        } else {
            switch proposal.presentation {
            case .default:
                navigate(with: controller, via: proposal)
            case .pop:
                pop()
            case .replace:
                replace(with: controller, via: proposal)
            case .refresh:
                refresh()
            case .clearAll:
                clearAll()
            case .replaceRoot:
                replaceRoot(with: controller)
            case .none:
                break // Do nothing.
            }
        }
    }

    // MARK: - SessionDelegate

    open func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        route(proposal)
    }

    open func sessionDidFinishFormSubmission(_ session: Session) {
        if session == modalSession {
            self.session.clearSnapshotCache()
        }
    }

    open func session(_ session: Session, openExternalURL url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            safariViewController.preferredControlTintColor = .tintColor
        }
        visibleViewController?.present(safariViewController, animated: true)
    }

    open func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        if let errorPresenter = visitable as? ErrorPresenter {
            errorPresenter.presentError(error) {
                session.reload()
            }
        }
    }

    open func sessionWebViewProcessDidTerminate(_ session: Session) {
        session.reload()
    }

    open func sessionDidLoadWebView(_ session: Session) {}
    open func sessionDidStartRequest(_ session: Session) {}
    open func sessionDidFinishRequest(_ session: Session) {}
    open func sessionDidStartFormSubmission(_ session: Session) {}

    // MARK: - WKUIDelegate

    open func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default) { _ in
            completionHandler()
        })
        visibleViewController?.present(alert, animated: true)
    }

    open func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive) { _ in
            completionHandler(true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        visibleViewController?.present(alert, animated: true)
    }

    // MARK: Internal

    let navigationController: UINavigationController
    let modalNavigationController: UINavigationController

    lazy var session = makeSession()
    lazy var modalSession = makeSession()

    // MARK: Private

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let pathConfiguration: PathConfiguration?

    private func makeSession() -> Session {
        let session = Session(webView: TurboConfig.shared.makeWebView())
        session.delegate = self
        session.pathConfiguration = pathConfiguration
        session.webView.uiDelegate = self
        return session
    }

    private func controller(for proposal: VisitProposal) -> UIViewController? {
        switch handle(proposal: proposal) {
        case .accept:
            return VisitableViewController(url: proposal.url)
        case .acceptCustom(let customViewController):
            return customViewController
        case .reject:
            return nil
        }
    }

    private func presentAlert(_ alert: UIAlertController) {
        if navigationController.presentedViewController != nil {
            modalNavigationController.present(alert, animated: true)
        } else {
            navigationController.present(alert, animated: true)
        }
    }

    private func navigate(with controller: UIViewController, via proposal: VisitProposal) {
        switch proposal.context {
        case .default:
            navigationController.dismiss(animated: true)
            pushOrReplace(on: navigationController, with: controller, via: proposal)
            visit(controller, on: session, with: proposal.options)
        case .modal:
            if navigationController.presentedViewController != nil {
                pushOrReplace(on: modalNavigationController, with: controller, via: proposal)
            } else {
                modalNavigationController.setViewControllers([controller], animated: false)
                navigationController.present(modalNavigationController, animated: true)
            }
            visit(controller, on: modalSession, with: proposal.options)
        }
    }

    private func pushOrReplace(on navigationController: UINavigationController, with controller: UIViewController, via proposal: VisitProposal) {
        if visitingSamePage(on: navigationController, with: controller, via: proposal.url) {
            navigationController.replaceLastViewController(with: controller)
        } else if visitingPreviousPage(on: navigationController, with: controller, via: proposal.url) {
            navigationController.popViewController(animated: true)
        } else if proposal.options.action == .advance {
            navigationController.pushViewController(controller, animated: true)
        } else {
            navigationController.replaceLastViewController(with: controller)
        }
    }

    private func visitingSamePage(on navigationController: UINavigationController, with controller: UIViewController, via url: URL) -> Bool {
        if let visitable = navigationController.topViewController as? Visitable {
            return visitable.visitableURL == url
        } else if let topViewController = navigationController.topViewController {
            return topViewController.isMember(of: type(of: controller))
        }
        return false
    }

    private func visitingPreviousPage(on navigationController: UINavigationController, with controller: UIViewController, via url: URL) -> Bool {
        guard navigationController.viewControllers.count >= 2 else { return false }

        let previousController = navigationController.viewControllers[navigationController.viewControllers.count - 2]
        if let previousVisitable = previousController as? VisitableViewController {
            return previousVisitable.visitableURL == url
        }
        return type(of: previousController) == type(of: controller)
    }

    private func pop() {
        if navigationController.presentedViewController != nil {
            if modalNavigationController.viewControllers.count == 1 {
                navigationController.dismiss(animated: true)
            } else {
                modalNavigationController.popViewController(animated: true)
            }
        } else {
            navigationController.popViewController(animated: true)
        }
    }

    private func replace(with controller: UIViewController, via proposal: VisitProposal) {
        switch proposal.context {
        case .default:
            navigationController.dismiss(animated: true)
            navigationController.replaceLastViewController(with: controller)
            visit(controller, on: session, with: proposal.options)
        case .modal:
            if navigationController.presentedViewController != nil {
                modalNavigationController.replaceLastViewController(with: controller)
            } else {
                modalNavigationController.setViewControllers([controller], animated: false)
                navigationController.present(modalNavigationController, animated: true)
            }
            visit(controller, on: modalSession, with: proposal.options)
        }
    }

    private func refresh() {
        if navigationController.presentedViewController != nil {
            if modalNavigationController.viewControllers.count == 1 {
                navigationController.dismiss(animated: true)
                session.reload()
            } else {
                modalNavigationController.popViewController(animated: true)
                modalSession.reload()
            }
        } else {
            navigationController.popViewController(animated: true)
            session.reload()
        }
    }

    private func clearAll() {
        navigationController.dismiss(animated: true)
        navigationController.popToRootViewController(animated: true)
        session.reload()
    }

    private func replaceRoot(with controller: UIViewController) {
        navigationController.dismiss(animated: true)
        navigationController.setViewControllers([controller], animated: true)

        if let visitable = controller as? Visitable {
            session.visit(visitable, action: .replace)
        }
    }

    private func visit(_ controller: UIViewController, on session: Session, with options: VisitOptions) {
        if let visitable = controller as? Visitable {
            session.visit(visitable, options: options)
        }
    }
}
