import SafariServices
import Turbo
import UIKit
import WebKit

/// Implement to be notified when certain navigations are performed
/// or to render a native controller instead of a Turbo web visit.
public protocol TurboNavigationDelegate: AnyObject {
    /// An error occurred loading the request, present it to the user.
    /// Retry the request by calling `session.reload()`.
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error)

    /// Optional. Implement if your web server is protected by basic auth.
    func session(_ session: Session, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)

    /// Optional. Implement to override or customize the controller to be displayed.
    /// Return `nil` to not display or route anything.
    func controller(_ controller: VisitableViewController, forProposal proposal: VisitProposal) -> UIViewController?

    /// Optional. Implement to customize handling of external URLs.
    /// If not implemented, will present `SFSafariViewController` as a modal and load the URL.
    func openExternalURL(_ url: URL, from controller: UIViewController)
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
}

/// Handles navigation to new URLs using the following rules:
/// https://masilotti.notion.site/Turbo-Native-iOS-navigation-4fd3dc638c3e4d2cab7ec5582656cbbb
public class TurboNavigator {
    public init(delegate: TurboNavigationDelegate, pathConfiguration: PathConfiguration? = nil, navigationController: UINavigationController = UINavigationController(), modalNavigationController: UINavigationController = UINavigationController()) {
        self.session = Session(webView: TurboConfig.shared.makeWebView())
        self.modalSession = Session(webView: TurboConfig.shared.makeWebView())
        self.delegate = delegate
        self.navigationController = navigationController
        self.modalNavigationController = modalNavigationController

        session.delegate = self
        modalSession.delegate = self
        session.pathConfiguration = pathConfiguration
        modalSession.pathConfiguration = pathConfiguration
    }

    public var rootViewController: UIViewController { navigationController }
    public let navigationController: UINavigationController
    public let modalNavigationController: UINavigationController

    public func route(_ url: URL) {
        let options = VisitOptions(action: .advance, response: nil)
        let properties = session.pathConfiguration?.properties(for: url) ?? PathProperties()
        let proposal = VisitProposal(url: url, options: options, properties: properties)
        route(proposal)
    }

    public func route(_ proposal: VisitProposal) {
        guard let controller = controller(for: proposal) else { return }

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
        }
    }

    // MARK: Internal

    let session: Session
    let modalSession: Session

    // MARK: Private

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private weak var delegate: TurboNavigationDelegate?

    private func controller(for proposal: VisitProposal) -> UIViewController? {
        let defaultController = VisitableViewController(url: proposal.url)
        guard let delegate = delegate else { return defaultController }

        // Developer can return nil from this method to break out of navigation.
        return delegate.controller(defaultController, forProposal: proposal)
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

// MARK: - SessionDelegate

extension TurboNavigator: SessionDelegate {
    public func session(_ session: Turbo.Session, didProposeVisit proposal: Turbo.VisitProposal) {
        route(proposal)
    }

    public func sessionDidFinishFormSubmission(_ session: Session) {
        if session == modalSession {
            self.session.clearSnapshotCache()
        }
    }

    public func session(_ session: Session, openExternalURL url: URL) {
        let controller = session === modalSession ? modalNavigationController : navigationController
        delegate?.openExternalURL(url, from: controller)
    }

    public func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        delegate?.session(session, didFailRequestForVisitable: visitable, error: error)
    }

    public func sessionWebViewProcessDidTerminate(_ session: Turbo.Session) {}

    public func session(_ session: Session, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
}
