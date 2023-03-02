import Turbo
import TurboNavigationController
import UIKit
import WebKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene
        else { fatalError("Expected a UIWindowScene.") }

        createWindow(in: windowScene)
    }

    // MARK: - Private

    private let baseURL = URL(string: "http://localhost:3000")!
    private let sharedProcessPool = WKProcessPool()
    private lazy var session = makeSession()
    private lazy var modalSession = makeSession()
    private lazy var pathConfiguration = PathConfiguration(sources: [
        .server(baseURL.appending(path: "/configuration"))
    ])
    private lazy var turboNavigationController = TurboNavigationController(session: session, modalSession: modalSession)

    private func createWindow(in windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .white
        self.window = window

        window.makeKeyAndVisible()
        window.rootViewController = turboNavigationController

        turboNavigationController.route(baseURL)
    }

    private func makeSession() -> Session {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "Turbo Native iOS"
        configuration.processPool = sharedProcessPool

        let session = Session(webViewConfiguration: configuration)
        session.pathConfiguration = pathConfiguration
        session.delegate = self
        return session
    }
}

extension SceneDelegate: SessionDelegate {
    func session(_ session: Turbo.Session, didProposeVisit proposal: Turbo.VisitProposal) {
        turboNavigationController.route(proposal)
    }

    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        print("An error occurred loading a visit:", error)
    }

    func sessionWebViewProcessDidTerminate(_ session: Turbo.Session) {}
}
