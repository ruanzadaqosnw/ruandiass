import UIKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let viewController = WebViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = true
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
}

// MARK: - Web View Controller (Mobile Optimized)

class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var loadingView: UIActivityIndicatorView?
    var progressView: UIProgressView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "IPA API Server"
        view.backgroundColor = .systemBackground
        
        // Configure WKWebView for mobile
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.ignoresViewportScaleLimits = false
        
        // Mobile viewport settings
        let preferences = WKPreferences()
        preferences.minimumFontSize = 12
        config.preferences = preferences
        
        // Enable viewport meta tag
        let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15"
        config.applicationNameForUserAgent = userAgent
        
        // Inject mobile CSS
        let mobileCss = """
        html, body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            overflow-x: hidden;
        }
        * {
            -webkit-user-select: none;
            user-select: none;
            -webkit-touch-callout: none;
        }
        input, textarea, select, button {
            -webkit-user-select: text;
            user-select: text;
        }
        body {
            font-size: 14px;
        }
        @media (max-width: 768px) {
            body { font-size: 13px; }
            h1 { font-size: 1.5rem; }
            h2 { font-size: 1.25rem; }
        }
        """
        
        let script = """
        var style = document.createElement('style');
        style.innerHTML = `\(mobileCss)`;
        document.head.appendChild(style);
        """
        
        let userScript = WKUserScript(
            source: script,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(userScript)
        
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Scroll view settings
        webView.scrollView.bounces = true
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        view.addSubview(webView)
        
        // Progress bar
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView?.tintColor = UIColor(red: 0.4, green: 0.2, blue: 1.0, alpha: 1.0)
        progressView?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 2)
        view.addSubview(progressView!)
        
        // Loading indicator
        loadingView = UIActivityIndicatorView(style: .medium)
        loadingView?.center = view.center
        loadingView?.color = UIColor(red: 0.4, green: 0.2, blue: 1.0, alpha: 1.0)
        view.addSubview(loadingView!)
        
        // Observe loading progress - Corrected as per user instructions
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        // Load server
        loadServer()
    }
    
    private func loadServer() {
        // Update this to your server URL
        let urlString = "https://ipa-api-server.vercel.app"
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
            loadingView?.startAnimating()
        } else {
            showErrorAlert("URL inválida", "Não foi possível carregar a URL: \(urlString)")
        }
    }
    
    // MARK: - Progress Observation - Corrected with @objc and string keyPath
    
    @objc override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "estimatedProgress" {
            progressView?.progress = Float(webView.estimatedProgress)
            
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.progressView?.alpha = 0
                })
            } else {
                progressView?.alpha = 1
            }
        }
    }
    
    deinit {
        if webView != nil {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
    }
    
    // MARK: - Navigation Delegate
    
    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        print("Started loading: \(webView.url?.absoluteString ?? "unknown")")
        loadingView?.startAnimating()
    }
    
    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        print("Finished loading")
        loadingView?.stopAnimating()
        
        // Inject mobile CSS after page load
        let css = """
        @media (max-width: 768px) {
            .sidebar { width: 100% !important; }
            .container { padding: 8px !important; }
        }
        """
        let script = "var s = document.createElement('style'); s.innerHTML = `\(css)`; document.head.appendChild(s);"
        webView.evaluateJavaScript(script)
    }
    
    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        print("Failed to load: \(error.localizedDescription)")
        loadingView?.stopAnimating()
        showErrorAlert("Erro de Conexão", error.localizedDescription)
    }
    
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        print("Failed provisional navigation: \(error.localizedDescription)")
        loadingView?.stopAnimating()
        
        // Retry button
        let alert = UIAlertController(
            title: "Erro de Conexão",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tentar Novamente", style: .default) { _ in
            self.loadServer()
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Helpers
    
    private func showErrorAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
