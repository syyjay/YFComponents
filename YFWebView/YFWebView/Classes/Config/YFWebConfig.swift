//
//  YFWebConfig.swift
//  YFWebView
//
//  WebView 配置
//

import UIKit
import WebKit

// MARK: - WebView 配置

public struct YFWebConfig {
    
    /// 是否显示进度条
    public var showProgressBar: Bool = true
    
    /// 进度条颜色
    public var progressColor: UIColor?
    
    /// 进度条高度
    public var progressHeight: CGFloat = 2.0
    
    /// 是否允许缩放
    public var allowsZoom: Bool = false
    
    /// 是否允许内联播放视频
    public var allowsInlineMediaPlayback: Bool = true
    
    /// 是否自动播放视频
    public var mediaAutoplay: Bool = false
    
    /// 是否允许 AirPlay
    public var allowsAirPlayForMediaPlayback: Bool = true
    
    /// 是否允许画中画
    public var allowsPictureInPicture: Bool = true
    
    /// 自定义 UserAgent（追加到默认 UA 后面）
    public var customUserAgent: String?
    
    /// 是否使用自定义 UserAgent 替换默认 UA
    public var replaceUserAgent: Bool = false
    
    /// 超时时间（秒）
    public var timeout: TimeInterval = 30.0
    
    /// 是否允许 JavaScript
    public var javaScriptEnabled: Bool = true
    
    /// 是否允许 JavaScript 打开窗口
    public var javaScriptCanOpenWindows: Bool = false
    
    /// 是否忽略 SSL 证书错误（仅用于调试）
    public var ignoreSSLError: Bool = false
    
    /// 默认配置
    public static let `default` = YFWebConfig()
    
    public init() {}
    
    /// 构建 WKWebViewConfiguration
    public func buildConfiguration() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        
        // 偏好设置
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = javaScriptCanOpenWindows
        config.preferences = preferences
        
        // 网页偏好设置
        let webpagePreferences = WKWebpagePreferences()
        webpagePreferences.allowsContentJavaScript = javaScriptEnabled
        config.defaultWebpagePreferences = webpagePreferences
        
        // 媒体播放设置
        config.allowsInlineMediaPlayback = allowsInlineMediaPlayback
        config.allowsAirPlayForMediaPlayback = allowsAirPlayForMediaPlayback
        config.allowsPictureInPictureMediaPlayback = allowsPictureInPicture
        
        if mediaAutoplay {
            config.mediaTypesRequiringUserActionForPlayback = []
        } else {
            config.mediaTypesRequiringUserActionForPlayback = .all
        }
        
        return config
    }
}

// MARK: - 链式配置

extension YFWebConfig {
    
    @discardableResult
    public func showProgressBar(_ show: Bool) -> YFWebConfig {
        var config = self
        config.showProgressBar = show
        return config
    }
    
    @discardableResult
    public func progressColor(_ color: UIColor) -> YFWebConfig {
        var config = self
        config.progressColor = color
        return config
    }
    
    @discardableResult
    public func allowsZoom(_ allows: Bool) -> YFWebConfig {
        var config = self
        config.allowsZoom = allows
        return config
    }
    
    @discardableResult
    public func customUserAgent(_ ua: String, replace: Bool = false) -> YFWebConfig {
        var config = self
        config.customUserAgent = ua
        config.replaceUserAgent = replace
        return config
    }
    
    @discardableResult
    public func timeout(_ seconds: TimeInterval) -> YFWebConfig {
        var config = self
        config.timeout = seconds
        return config
    }
}
