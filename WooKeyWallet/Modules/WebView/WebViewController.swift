//
//  WebViewController.swift
//

import UIKit
import WebKit


class WebViewController: BaseViewController {
    
    typealias Cookies = [String: String]
    
    
    // MARK: - Properties(Public)
    
    public let url: URL
    
    public let cookies: Cookies?
    
    public var autoWebViewTitle: Bool = true
    
    
    // MARK: - Properties(Private)
    
    private var webView: WKWebView!
    
    
    // MARK: - Properties(Lazy)
    
    private lazy var scriptMessager: WKScriptMessager = {
        let handler = WKScriptMessager.init(self)
        return handler
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = AppTheme.Color.text_click
        return progressView
    }()
    
    
    // MARK: - Life Circle
    
    init(_ url: URL, cookies: Cookies? = nil) {
        self.url = url
        self.cookies = cookies
        super.init()
        
        initWebView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initWebView() {
        let configuration = WKWebViewConfiguration.init()
        configuration.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = []
        } else {
            configuration.requiresUserActionForMediaPlayback = false
        }
        let preference = WKPreferences.init()
        preference.javaScriptEnabled = true
        preference.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preference
        configuration.userContentController = WKUserContentController.init()
        self.webView = WKWebView.init(frame: .zero, configuration: configuration)
        self.webView.backgroundColor = UIColor.black
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        if #available(iOS 11, *) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.webView.load(URLRequest(url: url))
        dPrint("webView.load")
        
        ///加载
        self.registJavaScriptMethods()
        self.setupCookies()
        
        /// 监听通知
        self.observeNotifications()
        
        /// KVO
        self.observeKVChanges()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getLeftBarButtonItems()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "navigationItem_refresh"), style: .plain, target: self, action: #selector(WebViewController.reloadAction))
        
        self.view.addSubview(self.webView)
        
        self.view.addSubview(self.progressView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11, *) {
            self.progressView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            self.progressView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        }
        self.progressView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.progressView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        self.progressView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        let top = 44 + UIApplication.shared.statusBarFrame.height
        self.webView.frame = view.bounds.inset(by: UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    deinit {
        // 解除持有
        removeJavaScriptMethods()
        
        // 解除kvo
        [
            (object: self.webView,
             keyPaths: [
                "estimatedProgress",
                "title"
                ]),
        ].forEach({
            (object, keyPaths) in
            keyPaths.forEach({
                object?.removeObserver(self, forKeyPath: $0)
            })
        })
    }
    
    // MARK: - Methods (Private)
    
    private func getLeftBarButtonItems() {
        if webView.canGoBack {
            self.navigationItem.leftBarButtonItems = [
                UIBarButtonItem.init(image: UIImage(named: "navigation_back_icon"), style: .plain, target: self, action: #selector(WebViewController.backAction)),
                UIBarButtonItem.init(image: UIImage(named: "navigation_button_close"), style: .plain, target: self, action: #selector(WebViewController.closeAction))
            ]
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "navigation_back_icon"), style: .plain, target: self, action: #selector(WebViewController.backAction))
        }
    }
    
    
    private func observeNotifications() {
        [
            (name: UIApplication.willResignActiveNotification, selector: #selector(WebViewController.applicationWillResignActive(_:))),
            (name: UIApplication.didBecomeActiveNotification, selector: #selector(WebViewController.applicationDidBecomeActive(_:))),
            (name: UIApplication.willEnterForegroundNotification, selector: #selector(WebViewController.applicationWillEnterForeground(_:))),
            (name: UIApplication.didEnterBackgroundNotification, selector: #selector(WebViewController.applicationDidEnterBackground(_:))),
        ].forEach({
            NotificationCenter.default.addObserver(self, selector: $0.selector, name: $0.name, object: nil)
        })
    }
    
    private func observeKVChanges() {
        [
            (object: self.webView,
             keyPaths: [
                "estimatedProgress",
                "title"
            ]),
        ].forEach({
            (object, keyPaths) in
            keyPaths.forEach({
                object?.addObserver(self, forKeyPath: $0, options: .new, context: nil)
            })
        })
    }
    
    private func registJavaScriptMethods() {
        
    }
    
    private func removeJavaScriptMethods() {
        
    }
    
    private func setupCookies() {
        guard let cookies = self.cookies else { return }
        var cookieString = ""
        cookies.forEach({ cookieString += "document.cookie = '\($0.key)=\($0.value)';" })
        let userScript = WKUserScript.init(source: cookieString, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        self.webView.configuration.userContentController.addUserScript(userScript)
    }
    
    private func evaluateJavaScript(_ method: String) {
        self.webView.evaluateJavaScript(method) { (data, error) in
            if let data = data {
                dPrint(data)
            }
            if let error = error {
                dPrint(error)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func backAction() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func closeAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func reloadAction() {
        webView.reload()
    }
    
    // MARK: - Notifications
    
    @objc func applicationWillResignActive(_ noti: Notification) {
        
    }
    
    @objc func applicationDidEnterBackground(_ noti: Notification) {
        
    }
    
    @objc func applicationDidBecomeActive(_ noti: Notification) {
        
    }
    
    @objc func applicationWillEnterForeground(_ noti: Notification) {
        
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressView.progress = Float(self.webView.estimatedProgress)
            if self.webView.estimatedProgress >= 1 {
                UIView.animate(withDuration: 0.25) {
                    self.progressView.progress = 0
                    self.progressView.alpha = 0
                }
            }else {
                self.progressView.alpha = 1
            }
        } else if keyPath == "title" {
            if autoWebViewTitle {
//                self.navigationItem.title = self.webView.title
            }
        }
    }
    
}


extension WebViewController: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    // MARK: - WKNavigationDelegate
    //1
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url {
                let webVC = WebViewController.init(url, cookies: cookies)
                navigationController?.pushViewController(webVC, animated: true)
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
        self.getLeftBarButtonItems()
        
        if let isItmsServices = navigationAction.request.url?.absoluteString.hasPrefix("itms-services"),
            isItmsServices,
            let url = navigationAction.request.url {
            UIApplication.shared.openURL(url)
        }
    }
    
    //2
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        getLeftBarButtonItems()
    }
    
    //3
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential , nil)
    }
    
    //4
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        getLeftBarButtonItems()
    }
    
    //5
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        let jsString1 = "localStorage.setItem('language', '\(AppLanguage.manager.current.rawValue)')"
        webView.evaluateJavaScript(jsString1, completionHandler: nil)
        let jsString2 = "localStorage.setItem('version', '\(AppInfo.appVersion)')"
        webView.evaluateJavaScript(jsString2, completionHandler: nil)
    }
    
    //6
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.getLeftBarButtonItems()
        self.navigationItem.title = webView.title
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        HUD.showError(error.localizedDescription)
        self.getLeftBarButtonItems()
    }
    
    // MARK: - WKUIDelegate
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (_) in
            completionHandler()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (_) in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: { (_) in
            completionHandler(false)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController.init(title: prompt, message: nil, preferredStyle: .alert)
        var tF: UITextField?
        alert.addTextField { (textField) in
            tF = textField
        }
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (_) in
            completionHandler(tF?.text)
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: { (_) in
            completionHandler(nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name.count > 0 {

        }
    }
}
