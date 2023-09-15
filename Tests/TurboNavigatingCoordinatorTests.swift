import SafariServices
import Turbo
@testable import TurboNavigator
import XCTest

final class TurboNavigatingCoordinatorTests: XCTestCase {
    
    func test_controllerForProposal_defaultsToVisitableViewController() throws {
        let url = URL(string: "https://example.com")!
        coordinator.rootNavigator.route(url)
        XCTAssert(coordinator.rootNavigator.navigationController.viewControllers.count == 1)
        XCTAssertNotNil(coordinator.rootNavigator.navigationController.viewControllers.first as? VisitableViewController)
    }

    func test_openExternalURL_presentsSafariViewController() throws {
        let url = URL(string: "https://example.com")!
        let controller = TestableNavigationController()

        coordinator.openExternalURL(url, from: controller)

        XCTAssert(controller.presentedViewController is SFSafariViewController)
        XCTAssertEqual(controller.modalPresentationStyle, .pageSheet)
    }

    // MARK: Private

    private let coordinator = TurboNavigatingCoordinator()
}

// MARK: - VisitProposal extension

private extension VisitProposal {
    init(url: URL) {
        let url = url
        let options = VisitOptions(action: .advance, response: nil)
        self.init(url: url, options: options)
    }
}
