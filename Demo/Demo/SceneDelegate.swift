import Turbo
import TurboNavigator
import UIKit

let baseURL = URL(string: "http://localhost:3000")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var turboNavigator = TurboNavigator(pathConfiguration: pathConfiguration)
    private let pathConfiguration = PathConfiguration(sources: [
        .server(baseURL.appendingPathComponent("/configurations/ios_v1.json"))
    ])

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        self.window = UIWindow(windowScene: windowScene)
        self.window?.makeKeyAndVisible()

        self.window?.rootViewController = self.turboNavigator.rootViewController
        self.turboNavigator.route(baseURL)
    }
}

import WebKit

/// This example class shows how one can use more features of Turbo Navigator.
class ComplexSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var turboNavigator = TurboNavigator(pathConfiguration: pathConfiguration, delegate: self)
    private let pathConfiguration = PathConfiguration(sources: [
        .server(baseURL.appendingPathComponent("/configurations/ios_v1.json"))
    ])

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        TurboConfig.shared.userAgent += " CUSTOM STRADA USER AGENT"
        TurboConfig.shared.makeCustomWebView = { config in
            let webView = WKWebView(frame: .zero, configuration: config)
            // Bridge.initialize(webView)
            return webView
        }

        self.turboNavigator.webkitUIDelegate = ExampleWKUIController(delegate: self.turboNavigator)

        self.window = UIWindow(windowScene: windowScene)
        self.window?.makeKeyAndVisible()

        self.window?.rootViewController = self.turboNavigator.rootViewController
        self.turboNavigator.route(baseURL)
    }
}

extension ComplexSceneDelegate: TurboNavigatorDelegate {
    func handle(proposal: VisitProposal) -> ProposalResult {
        switch proposal.viewController {
            case "example": .acceptCustom(ExampleViewController())
            default: .accept
        }
    }
}

class ExampleViewController: UIViewController {}

class ExampleWKUIController: TurboWKUIController {
    // Overridden: custom handling of confirm() dialog.
    override func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }

    // New function: custom handling of prompt() dialog.
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        completionHandler("Hi!")
    }
}
