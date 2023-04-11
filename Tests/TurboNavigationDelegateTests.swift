import SafariServices
import Turbo
@testable import TurboNavigator
import XCTest

final class TurboNavigationDelegateTests: XCTestCase {
    func test_controllerForProposal_defaultsToVisitableViewController() throws {
        let url = URL(string: "https://example.com")!

        let controller = delegate.controller(VisitableViewController(), forProposal: VisitProposal(url: url))

        let visitableViewController = try XCTUnwrap(controller as? VisitableViewController)
        XCTAssertEqual(visitableViewController.visitableURL, url)
    }

    func test_openExternalURL_presentsSafariViewController() throws {
        let url = URL(string: "https://example.com")!
        let controller = TestableNavigationController()

        delegate.openExternalURL(url, from: controller)

        XCTAssert(controller.presentedViewController is SFSafariViewController)
        XCTAssertEqual(controller.modalPresentationStyle, .pageSheet)
    }

    // MARK: Private

    private let delegate = DefaultDelegate()
}

// MARK: - DefaultDelegate

private class DefaultDelegate: TurboNavigationDelegate {
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {}
}

// MARK: - VisitProposal extension

private extension VisitProposal {
    init(url: URL) {
        let url = url
        let options = VisitOptions(action: .advance, response: nil)
        self.init(url: url, options: options)
    }
}
