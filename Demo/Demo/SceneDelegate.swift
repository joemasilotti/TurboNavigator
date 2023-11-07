import Turbo
import TurboNavigator
import UIKit

let baseURL = URL(string: "http://localhost:3000")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var turboNavigator: TurboNavigator!

    private lazy var pathConfiguration = PathConfiguration(sources: [
        .server(baseURL.appendingPathComponent("/configurations/ios_v1.json"))
    ])

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let mainSession = Session(webView: TurboConfig.shared.makeWebView())
        mainSession.pathConfiguration = self.pathConfiguration

        let modalSession = Session(webView: TurboConfig.shared.makeWebView())
        modalSession.pathConfiguration = self.pathConfiguration

        self.turboNavigator = TurboNavigator(session: mainSession, modalSession: modalSession)

        self.window = UIWindow(windowScene: windowScene)
        self.window?.makeKeyAndVisible()

        self.window?.rootViewController = self.turboNavigator.rootViewController
        self.turboNavigator.route(baseURL)
    }
}
