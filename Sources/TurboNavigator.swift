import SafariServices
import Turbo
import UIKit
import WebKit

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

    // MARK: Internal

    let session: Session
    let modalSession: Session

    // MARK: Private

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private unowned let delegate: TurboNavigationDelegate

    private func controller(for proposal: VisitProposal) -> UIViewController? {
        let defaultController = VisitableViewController(url: proposal.url)
        return delegate.controller(defaultController, forProposal: proposal)
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

// MARK: - SessionDelegate

extension TurboNavigator: SessionDelegate {
    public func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        route(proposal)
    }

    public func sessionDidFinishFormSubmission(_ session: Session) {
        if session == modalSession {
            self.session.clearSnapshotCache()
        }
    }

    public func session(_ session: Session, openExternalURL url: URL) {
        let controller = session === modalSession ? modalNavigationController : navigationController
        delegate.openExternalURL(url, from: controller)
    }

    public func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        delegate.visitableDidFailRequest(visitable, error: error) {
            session.reload()
        }
    }

    public func sessionWebViewProcessDidTerminate(_ session: Session) {
        session.reload()
    }

    public func session(_ session: Session, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        delegate.didReceiveAuthenticationChallenge(challenge, completionHandler: completionHandler)
    }

    public func sessionDidLoadWebView(_ session: Session) {
        session.webView.navigationDelegate = session
        delegate.sessionDidLoadWebView(session)
    }

    public func sessionDidStartRequest(_ session: Session) {
        delegate.sessionDidStartRequest(session)
    }
}
