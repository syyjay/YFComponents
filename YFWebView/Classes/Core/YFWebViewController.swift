//
//  YFWebViewController.swift
//  YFWebView
//
//  WebView 控制器
//

import UIKit
import WebKit
import YFUIKit
import YFLogger
import SnapKit

/// WebView 控制器
open class YFWebViewController: YFBaseViewController, YFWebViewDelegate {
    
    // MARK: - Properties
    
    /// WebView
    public lazy var webView: YFWebView = {
        let wv = YFWebView(config: webConfig)
        wv.delegate = self
        return wv
    }()
    
    /// 配置
    public var webConfig: YFWebConfig = .default
    
    /// 初始 URL
    public var initialURL: URL?
    
    /// 初始 HTML
    public var initialHTML: String?
    
    /// 是否自动更新标题
    public var autoUpdateTitle: Bool = true
    
    /// 是否显示关闭按钮（当有历史记录时）
    public var showCloseButton: Bool = true
    
    /// 关闭按钮
    private var closeButton: UIButton?
    
    // MARK: - Init
    
    public convenience init(url: URL, config: YFWebConfig = .default) {
        self.init()
        self.initialURL = url
        self.webConfig = config
    }
    
    public convenience init(urlString: String, config: YFWebConfig = .default) {
        self.init()
        self.initialURL = URL(string: urlString)
        self.webConfig = config
    }
    
    public convenience init(html: String, config: YFWebConfig = .default) {
        self.init()
        self.initialHTML = html
        self.webConfig = config
    }
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        loadContent()
    }
    
    // MARK: - Setup
    
    open override func setupNavigation() {
        setTitle("加载中...")
    }
    
    open override func setupUI() {
        view.addSubview(webView)
    }
    
    open override func setupConstraints() {
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - 加载内容
    
    private func loadContent() {
        if let url = initialURL {
            webView.load(url: url)
        } else if let html = initialHTML {
            webView.load(html: html)
        }
    }
    
    // MARK: - 导航按钮
    
    private func updateNavigationButtons() {
        guard showCloseButton else { return }
        
        if webView.canGoBack && closeButton == nil {
            // 添加关闭按钮
            let button = UIButton(type: .system)
            button.setTitle("关闭", for: .normal)
            button.setTitleColor(.themed(\.textPrimary), for: .normal)
            button.titleLabel?.font = theme.typography.body
            button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
            
            // 添加到导航栏左侧
            navigationBar.addLeftButton(title: "关闭", target: self, action: #selector(closeTapped))
            closeButton = button
        } else if !webView.canGoBack && closeButton != nil {
            // 移除关闭按钮
            closeButton = nil
            // 重新设置返回按钮
            if navigationController?.viewControllers.count ?? 0 > 1 {
                navigationBar.setBackButton(target: self, action: #selector(backAction))
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func backAction() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            closeTapped()
        }
    }
    
    // MARK: - 公共方法
    
    /// 加载 URL
    public func load(url: URL) {
        webView.load(url: url)
    }
    
    /// 加载 URL 字符串
    public func load(urlString: String) {
        webView.load(urlString: urlString)
    }
    
    /// 加载 HTML
    public func load(html: String, baseURL: URL? = nil) {
        webView.load(html: html, baseURL: baseURL)
    }
    
    /// 刷新
    public func reload() {
        webView.reload()
    }
    
    /// 后退
    public override func goBack() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            super.goBack()
        }
    }
    
    /// 前进
    public func goForward() {
        webView.goForward()
    }
    
    // MARK: - YFWebViewDelegate
    
    open func webViewDidStartLoad(_ webView: YFWebView) {
        // 子类可重写
    }
    
    open func webViewDidFinishLoad(_ webView: YFWebView) {
        updateNavigationButtons()
    }
    
    open func webView(_ webView: YFWebView, didFailWithError error: Error) {
        // 显示错误提示
        let nsError = error as NSError
        // 忽略取消加载的错误
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            return
        }
        YFToast.error(error.localizedDescription)
    }
    
    open func webView(_ webView: YFWebView, didUpdateProgress progress: Float) {
        // 子类可重写
    }
    
    open func webView(_ webView: YFWebView, didUpdateTitle title: String?) {
        if autoUpdateTitle, let title = title, !title.isEmpty {
            setTitle(title)
        }
    }
    
    open func webView(_ webView: YFWebView, shouldInterceptURL url: URL) -> Bool {
        // 子类可重写
        return false
    }
}

// MARK: - 快捷方法

extension YFWebViewController {
    
    /// 打开 URL
    public static func open(url: URL, from viewController: UIViewController, config: YFWebConfig = .default) {
        let webVC = YFWebViewController(url: url, config: config)
        viewController.navigationController?.pushViewController(webVC, animated: true)
    }
    
    /// 打开 URL 字符串
    public static func open(urlString: String, from viewController: UIViewController, config: YFWebConfig = .default) {
        guard let url = URL(string: urlString) else {
            logE("无效的 URL: \(urlString)")
            return
        }
        open(url: url, from: viewController, config: config)
    }
    
    /// 模态打开
    public static func present(url: URL, from viewController: UIViewController, config: YFWebConfig = .default) {
        let webVC = YFWebViewController(url: url, config: config)
        let nav = YFNavigationController(rootViewController: webVC)
        
        // 添加关闭按钮
        webVC.navigationBar.addRightButton(title: "关闭", target: webVC, action: #selector(dismissSelf))
        
        nav.modalPresentationStyle = .fullScreen
        viewController.present(nav, animated: true)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}
