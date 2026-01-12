//
//  YFWebView.swift
//  YFWebView
//
//  核心 WebView 封装
//

import UIKit
import WebKit
import YFUIKit
import YFLogger
import SnapKit

// MARK: - 代理协议

public protocol YFWebViewDelegate: AnyObject {
    /// 开始加载
    func webViewDidStartLoad(_ webView: YFWebView)
    /// 加载完成
    func webViewDidFinishLoad(_ webView: YFWebView)
    /// 加载失败
    func webView(_ webView: YFWebView, didFailWithError error: Error)
    /// 进度变化
    func webView(_ webView: YFWebView, didUpdateProgress progress: Float)
    /// 标题变化
    func webView(_ webView: YFWebView, didUpdateTitle title: String?)
    /// URL 拦截（返回 true 表示拦截，不继续加载）
    func webView(_ webView: YFWebView, shouldInterceptURL url: URL) -> Bool
    /// 收到 JS Alert
    func webView(_ webView: YFWebView, runJavaScriptAlertWithMessage message: String, completion: @escaping () -> Void)
    /// 收到 JS Confirm
    func webView(_ webView: YFWebView, runJavaScriptConfirmWithMessage message: String, completion: @escaping (Bool) -> Void)
    /// 收到 JS Prompt
    func webView(_ webView: YFWebView, runJavaScriptTextInputWithPrompt prompt: String, defaultText: String?, completion: @escaping (String?) -> Void)
}

// MARK: - 默认实现

// MARK: - 默认实现（仅 JS 弹窗相关）

public extension YFWebViewDelegate {
    func webView(_ webView: YFWebView, runJavaScriptAlertWithMessage message: String, completion: @escaping () -> Void) {
        YFAlertController.alert(title: nil, message: message, handler: completion)
    }
    
    func webView(_ webView: YFWebView, runJavaScriptConfirmWithMessage message: String, completion: @escaping (Bool) -> Void) {
        YFAlertController.confirm(title: nil, message: message, onCancel: {
            completion(false)
        }, onConfirm: {
            completion(true)
        })
    }
    
    func webView(_ webView: YFWebView, runJavaScriptTextInputWithPrompt prompt: String, defaultText: String?, completion: @escaping (String?) -> Void) {
        YFAlertController.prompt(title: prompt, defaultText: defaultText, onConfirm: { text in
            completion(text)
        })
    }
}

// MARK: - YFWebView

public class YFWebView: UIView {
    
    // MARK: - Properties
    
    /// 代理
    public weak var delegate: YFWebViewDelegate?
    
    /// 配置
    public private(set) var config: YFWebConfig
    
    /// JS 桥接
    public let jsBridge = YFJSBridge()
    
    /// 当前 URL
    public var currentURL: URL? {
        return webView.url
    }
    
    /// 当前标题
    public var title: String? {
        return webView.title
    }
    
    /// 是否可以后退
    public var canGoBack: Bool {
        return webView.canGoBack
    }
    
    /// 是否可以前进
    public var canGoForward: Bool {
        return webView.canGoForward
    }
    
    /// 是否正在加载
    public var isLoading: Bool {
        return webView.isLoading
    }
    
    /// 加载进度
    public var estimatedProgress: Double {
        return webView.estimatedProgress
    }
    
    /// 内部 WKWebView（仅在需要高级功能时使用）
    public var internalWebView: WKWebView {
        return webView
    }
    
    // MARK: - UI
    
    private lazy var webView: WKWebView = {
        let configuration = config.buildConfiguration()
        jsBridge.configure(contentController: configuration.userContentController)
        
        let wv = WKWebView(frame: .zero, configuration: configuration)
        wv.navigationDelegate = self
        wv.uiDelegate = self
        wv.allowsBackForwardNavigationGestures = true
        
        // 设置 UserAgent
        if let customUA = config.customUserAgent {
            if config.replaceUserAgent {
                wv.customUserAgent = customUA
            } else {
                wv.evaluateJavaScript("navigator.userAgent") { [weak wv] result, _ in
                    if let ua = result as? String {
                        wv?.customUserAgent = ua + " " + customUA
                    }
                }
            }
        }
        
        return wv
    }()
    
    private lazy var progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.progressTintColor = config.progressColor ?? .themed(\.primary)
        pv.trackTintColor = .clear
        pv.isHidden = true
        return pv
    }()
    
    // MARK: - KVO
    
    private var progressObservation: NSKeyValueObservation?
    private var titleObservation: NSKeyValueObservation?
    
    // MARK: - Init
    
    public init(config: YFWebConfig = .default) {
        self.config = config
        super.init(frame: .zero)
        setupUI()
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        self.config = .default
        super.init(coder: coder)
        setupUI()
        setupObservers()
    }
    
    deinit {
        progressObservation?.invalidate()
        titleObservation?.invalidate()
        webView.configuration.userContentController.removeScriptMessageHandler(forName: YFJSBridge.bridgeName)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(webView)
        addSubview(progressView)
        
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        progressView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(config.progressHeight)
        }
        
        jsBridge.configure(with: webView)
        
        // 禁止缩放
        if !config.allowsZoom {
            let script = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);
            """
            let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(userScript)
        }
    }
    
    private func setupObservers() {
        // 进度监听
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            guard let self = self else { return }
            let progress = Float(webView.estimatedProgress)
            
            if self.config.showProgressBar {
                self.progressView.isHidden = false
                self.progressView.setProgress(progress, animated: true)
                
                if progress >= 1.0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.progressView.isHidden = true
                        self.progressView.setProgress(0, animated: false)
                    }
                }
            }
            
            self.delegate?.webView(self, didUpdateProgress: progress)
        }
        
        // 标题监听
        titleObservation = webView.observe(\.title, options: [.new]) { [weak self] webView, _ in
            guard let self = self else { return }
            self.delegate?.webView(self, didUpdateTitle: webView.title)
        }
    }
    
    // MARK: - 加载方法
    
    /// 加载 URL
    @discardableResult
    public func load(url: URL, timeout: TimeInterval? = nil) -> WKNavigation? {
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout ?? config.timeout
        logD("加载 URL: \(url.absoluteString)")
        return webView.load(request)
    }
    
    /// 加载 URL 字符串
    @discardableResult
    public func load(urlString: String) -> WKNavigation? {
        guard let url = URL(string: urlString) else {
            logE("无效的 URL: \(urlString)")
            return nil
        }
        return load(url: url)
    }
    
    /// 加载 HTML 字符串
    @discardableResult
    public func load(html: String, baseURL: URL? = nil) -> WKNavigation? {
        logD("加载 HTML")
        return webView.loadHTMLString(html, baseURL: baseURL)
    }
    
    /// 加载本地文件
    @discardableResult
    public func load(fileURL: URL, allowingReadAccessTo directory: URL? = nil) -> WKNavigation? {
        let accessURL = directory ?? fileURL.deletingLastPathComponent()
        logD("加载本地文件: \(fileURL.path)")
        return webView.loadFileURL(fileURL, allowingReadAccessTo: accessURL)
    }
    
    /// 加载 Bundle 中的文件
    @discardableResult
    public func load(fileName: String, extension ext: String, bundle: Bundle = .main) -> WKNavigation? {
        guard let fileURL = bundle.url(forResource: fileName, withExtension: ext) else {
            logE("未找到文件: \(fileName).\(ext)")
            return nil
        }
        return load(fileURL: fileURL)
    }
    
    // MARK: - 导航控制
    
    /// 后退
    @discardableResult
    public func goBack() -> WKNavigation? {
        return webView.goBack()
    }
    
    /// 前进
    @discardableResult
    public func goForward() -> WKNavigation? {
        return webView.goForward()
    }
    
    /// 刷新
    @discardableResult
    public func reload() -> WKNavigation? {
        return webView.reload()
    }
    
    /// 强制刷新（忽略缓存）
    @discardableResult
    public func reloadFromOrigin() -> WKNavigation? {
        return webView.reloadFromOrigin()
    }
    
    /// 停止加载
    public func stopLoading() {
        webView.stopLoading()
    }
    
    // MARK: - JS 交互
    
    /// 执行 JavaScript
    public func evaluateJavaScript(_ script: String, completion: ((Result<Any?, Error>) -> Void)? = nil) {
        jsBridge.evaluateJavaScript(script, completion: completion)
    }
    
    /// 调用 JS 方法
    public func callJS(method: String, params: Any? = nil, completion: ((Result<Any?, Error>) -> Void)? = nil) {
        jsBridge.callJS(method: method, params: params, completion: completion)
    }
    
    /// 注册 JS 处理器
    public func registerJSHandler(name: String, handler: @escaping (Any, @escaping (Any?) -> Void) -> Void) {
        jsBridge.register(name: name, handler: handler)
    }
    
    // MARK: - 清理
    
    /// 清除缓存
    public func clearCache(completion: (() -> Void)? = nil) {
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: date) {
            logD("清除 WebView 缓存")
            completion?()
        }
    }
    
    /// 清除 Cookie
    public func clearCookies(completion: (() -> Void)? = nil) {
        YFCookieManager.shared.deleteAllCookies(completion: completion)
    }
}

// MARK: - WKNavigationDelegate

extension YFWebView: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        logD("开始加载")
        delegate?.webViewDidStartLoad(self)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        logD("加载完成")
        delegate?.webViewDidFinishLoad(self)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        logE("加载失败: \(error.localizedDescription)")
        delegate?.webView(self, didFailWithError: error)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        logE("加载失败: \(error.localizedDescription)")
        delegate?.webView(self, didFailWithError: error)
    }
    
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        // URL 拦截
        if delegate?.webView(self, shouldInterceptURL: url) == true {
            logD("拦截 URL: \(url.absoluteString)")
            decisionHandler(.cancel)
            return
        }
        
        // 处理特殊 scheme
        let scheme = url.scheme ?? ""
        if !["http", "https", "file", "about"].contains(scheme) {
            // 尝试打开外部应用
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
    public func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // SSL 证书处理
        if config.ignoreSSLError,
           challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

// MARK: - WKUIDelegate

extension YFWebView: WKUIDelegate {
    
    public func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        delegate?.webView(self, runJavaScriptAlertWithMessage: message, completion: completionHandler)
    }
    
    public func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void
    ) {
        delegate?.webView(self, runJavaScriptConfirmWithMessage: message, completion: completionHandler)
    }
    
    public func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (String?) -> Void
    ) {
        delegate?.webView(self, runJavaScriptTextInputWithPrompt: prompt, defaultText: defaultText, completion: completionHandler)
    }
    
    public func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        // 处理 target="_blank" 的链接
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
