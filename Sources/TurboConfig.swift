import Strada
import WebKit

public class TurboConfig {
    public typealias WebViewBlock = (_ configuration: WKWebViewConfiguration) -> WKWebView

    public static let shared = TurboConfig()

    /// Set the class names of your Strada components to generate the correct user agent.
    public var stradaComponentTypes = [BridgeComponent.Type]()

    /// Override to set a custom user agent.
    /// Include "Turbo Native" to use `turbo_native_app?` on your Rails server.
    public lazy var userAgent = {
        let stradaSubstring = Strada.userAgentSubstring(for: stradaComponentTypes)
        return "Turbo Native iOS \(stradaSubstring)"
    }()

    /// Optionally customize the web views used by each Turbo Session.
    /// Ensure you return a new instance each time.
    public var makeCustomWebView: WebViewBlock = { (configuration: WKWebViewConfiguration) in
        let webView = WKWebView(frame: .zero, configuration: configuration)
        Bridge.initialize(webView)
        return webView
    }

    // MARK: - Internal

    func makeWebView() -> WKWebView {
        makeCustomWebView(makeWebViewConfiguration())
    }

    // MARK: - Private

    private let sharedProcessPool = WKProcessPool()

    private init() {}

    // A method (not a property) because we need a new instance for each web view.
    private func makeWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = userAgent
        configuration.processPool = sharedProcessPool
        return configuration
    }
}
