import WebKit

public protocol ControllerProvider: AnyObject {
    var visibleViewController: UIViewController? { get }
}

open class WebViewDelegate: NSObject, WKUIDelegate {
    private unowned let controllerProvider: ControllerProvider

    public init(controllerProvider: ControllerProvider) {
        self.controllerProvider = controllerProvider
    }

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        guard let controller = controllerProvider.visibleViewController else { return }
        
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default) { _ in
            completionHandler()
        })
        controller.present(alert, animated: true)
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        guard let controller = controllerProvider.visibleViewController else { return }
        
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive) { _ in
            completionHandler(true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        controller.present(alert, animated: true)
    }
}
