import SafariServices
import Turbo
@testable import TurboNavigator
import XCTest

final class TurboNavigationDelegateTests: XCTestCase {
    func test_controllerForProposal_defaultsToVisitableViewController() throws {
        let url = URL(string: "https://example.com")!

        let result = delegate.handle(proposal: VisitProposal(url: url))

        XCTAssertEqual(result, .accept)
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
