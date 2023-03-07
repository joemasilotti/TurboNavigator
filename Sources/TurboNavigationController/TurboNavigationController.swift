import Turbo
import UIKit
import WebKit

/// Implement to be notified when certain navigations are performed
/// or to render a native controller instead of a Turbo web visit.
public protocol TurboNavigationDelegate: AnyObject {
    /// Return false to break out of default controller management.
    func shouldRoute(_ proposal: VisitProposal) -> Bool

    /// Implement to return a custom native controller to be displayed.
    /// Defaults to VisitableViewController for default Turbo Native behavior.
    func customController(for proposal: VisitProposal) -> UIViewController?

    /// An error occurred loading the request, present it to the user.
    /// Retry the request by calling `session.reload()`.
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error)

    func makeWebView() -> WKWebView
}

public extension TurboNavigationDelegate {
    func shouldRoute(_ proposal: VisitProposal) -> Bool {
        true
    }

    func customController(for proposal: VisitProposal) -> UIViewController? {
        VisitableViewController(url: proposal.url)
    }

    func makeWebView() -> WKWebView  {
        TurboConfig.shared.makeWebView()
    }
}

/// Handles navigation to new URLs using the following rules:
/// https://masilotti.notion.site/Turbo-Native-iOS-navigation-4fd3dc638c3e4d2cab7ec5582656cbbb
public class TurboNavigationController: UINavigationController {
    public init(navigationDelegate: TurboNavigationDelegate, pathConfiguration: PathConfiguration? = nil) {
        self.session = Session(webView: navigationDelegate.makeWebView())
        self.modalSession = Session(webView: navigationDelegate.makeWebView())
        self.navigationDelegate = navigationDelegate
        super.init(nibName: nil, bundle: nil)

        session.delegate = self
        modalSession.delegate = self
        session.pathConfiguration = pathConfiguration
        modalSession.pathConfiguration = pathConfiguration
    }

    public func route(_ url: URL) {
        let options = VisitOptions(action: .advance, response: nil)
        let proposal = VisitProposal(url: url, options: options)
        route(proposal)
    }

    public func route(_ proposal: VisitProposal) {
        if navigationDelegate?.shouldRoute(proposal) ?? true {
            _route(proposal)
        }
    }

    // MARK: Private

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let session: Session
    private let modalSession: Session
    private weak var navigationDelegate: TurboNavigationDelegate?
    private let modalNavigationController = UINavigationController()

    private func _route(_ proposal: VisitProposal) {
        let controller = controller(for: proposal)
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

    private func controller(for proposal: VisitProposal) -> UIViewController {
        navigationDelegate?.customController(for: proposal) ?? VisitableViewController(url: proposal.url)
    }

    private func navigate(with controller: UIViewController, via proposal: VisitProposal) {
        switch proposal.context {
        case .default:
            presentedViewController?.dismiss(animated: true)
            pushOrReplace(on: self, with: controller, via: proposal)
            visit(controller, on: session, with: proposal.options)
        case .modal:
            if presentedViewController != nil {
                pushOrReplace(on: modalNavigationController, with: controller, via: proposal)
            } else {
                modalNavigationController.setViewControllers([controller], animated: false)
                present(modalNavigationController, animated: true)
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
        if presentedViewController != nil {
            if modalNavigationController.viewControllers.count == 1 {
                presentedViewController?.dismiss(animated: true)
            } else {
                modalNavigationController.popViewController(animated: true)
            }
        } else {
            popViewController(animated: true)
        }
    }

    private func replace(with controller: UIViewController, via proposal: VisitProposal) {
        switch proposal.context {
        case .default:
            presentedViewController?.dismiss(animated: true)
            replaceLastViewController(with: controller)
            visit(controller, on: session, with: proposal.options)
        case .modal:
            if presentedViewController != nil {
                modalNavigationController.replaceLastViewController(with: controller)
            } else {
                modalNavigationController.setViewControllers([controller], animated: false)
                present(modalNavigationController, animated: true)
            }
            visit(controller, on: modalSession, with: proposal.options)
        }
    }

    private func refresh() {
        if presentedViewController != nil {
            if modalNavigationController.viewControllers.count == 1 {
                presentedViewController?.dismiss(animated: true)
                session.reload()
            } else {
                modalNavigationController.popViewController(animated: true)
                modalSession.reload()
            }
        } else {
            popViewController(animated: true)
            session.reload()
        }
    }

    private func clearAll() {
        presentedViewController?.dismiss(animated: true)
        popToRootViewController(animated: true)
        session.reload()
    }

    private func replaceRoot(with controller: UIViewController) {
        presentedViewController?.dismiss(animated: true)
        setViewControllers([controller], animated: true)

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

extension TurboNavigationController: SessionDelegate {
    public func session(_ session: Turbo.Session, didProposeVisit proposal: Turbo.VisitProposal) {
        route(proposal)
    }

    public func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        // TODO: Provide a default error screen with option to provide a custom one.
        navigationDelegate?.session(session, didFailRequestForVisitable: visitable, error: error)
    }

    public func sessionWebViewProcessDidTerminate(_ session: Turbo.Session) {
        // TODO: Handle a terminated web view process or pass to the delegate.
    }
}
