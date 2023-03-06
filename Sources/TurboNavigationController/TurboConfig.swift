import Turbo
import WebKit

public class TurboConfig {
    public static let shared = TurboConfig()

    /// Override to set a custom user agent.
    /// Include "Turbo Native" to use `turbo_native_app?` on your Rails server.
    public var userAgent = "Turbo Native iOS"

    // MARK: - Internal

    func makeWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = userAgent
        configuration.processPool = sharedProcessPool
        return WKWebView(frame: .zero, configuration: configuration)
    }

    // MARK: - Private

    private let sharedProcessPool = WKProcessPool()

    private init() {}
}
