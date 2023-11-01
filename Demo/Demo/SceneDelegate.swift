import Turbo
import TurboNavigator
import UIKit

let baseURL = URL(string: "http://localhost:3000")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var turboNavigator = TurboNavigator(delegate: self, pathConfiguration: pathConfiguration)
    private lazy var pathConfiguration = PathConfiguration(sources: [
        .server(baseURL.appendingPathComponent("/configuration"))
    ])

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        self.window = UIWindow(windowScene: windowScene)
        self.window?.makeKeyAndVisible()

        self.window?.rootViewController = self.turboNavigator.rootViewController
        self.turboNavigator.route(baseURL)
    }
}

extension SceneDelegate: TurboNavigationDelegate {}
