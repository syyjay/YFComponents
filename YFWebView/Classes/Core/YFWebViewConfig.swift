//
//  YFWebViewConfig.swift
//  YFWebView
//
//  WebView 配置
//

import UIKit
import WebKit

/// WebView 配置
public struct YFWebViewConfig {
    
    // MARK: - 进度条
    
    /// 是否显示进度条
    public var showProgressBar: Bool = true
    
    /// 进度条颜色
    public var progressColor: UIColor = .systemBlue
    
    /// 进度条高度
    public var progressHeight: CGFloat = 2
    
    // MARK: - 行为
    
    /// 是否允许缩放
    public var allowsZoom: Bool = true
    
    /// 是否允许后退手势
    public var allowsBackForwardGestures: Bool = true
    
    /// 是否允许内联播放视频
    public var allowsInlineMediaPlayback: Bool = true
    
    /// 是否自动播放视频
    public var mediaAutoplay: Bool = false
    
    // MARK: - JavaScript
    
    /// 是否启用 JavaScript
    public var javaScriptEnabled: Bool = true
    
    /// 自定义 UserAgent（追加到默认 UA 后面）
    public var customUserAgent: String?
    
    /// 完全自定义 UserAgent（替换默认 UA）
    public var applicationNameForUserAgent: String?
    
    // MARK: - 其他
    
    /// 是否透明背景
    public var isOpaque: Bool = true
    
    /// 背景颜色
    public var backgroundColor: UIColor = .white
    
    /// 滚动条样式
    public var scrollIndicatorStyle: UIScrollView.IndicatorStyle = .default
    
    /// 是否显示水平滚动条
    public var showsHorizontalScrollIndicator: Bool = true
    
    /// 是否显示垂直滚动条
    public var showsVerticalScrollIndicator: Bool = true
    
    /// 是否启用拉伸回弹效果
    public var bounces: Bool = true
    
    // MARK: - Init
    
    public init() {}
    
    /// 快速创建配置
    public static func make(_ configure: (inout YFWebViewConfig) -> Void) -> YFWebViewConfig {
        var config = YFWebViewConfig()
        configure(&config)
        return config
    }
    
    // MARK: - 预设配置
    
    /// 默认配置
    public static var `default`: YFWebViewConfig {
        return YFWebViewConfig()
    }
    
    /// 无进度条配置
    public static var noProgress: YFWebViewConfig {
        var config = YFWebViewConfig()
        config.showProgressBar = false
        return config
    }
    
    /// 全屏视频配置
    public static var fullscreenVideo: YFWebViewConfig {
        var config = YFWebViewConfig()
        config.allowsInlineMediaPlayback = false
        config.mediaAutoplay = true
        return config
    }
}

// MARK: - WKWebViewConfiguration 扩展

extension YFWebViewConfig {
    
    /// 转换为 WKWebViewConfiguration
    func toWKConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        
        // JavaScript 设置
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences
        
        // 网页设置
        let pagePrefs = WKWebpagePreferences()
        pagePrefs.allowsContentJavaScript = javaScriptEnabled
        configuration.defaultWebpagePreferences = pagePrefs
        
        // 媒体设置
        configuration.allowsInlineMediaPlayback = allowsInlineMediaPlayback
        configuration.mediaTypesRequiringUserActionForPlayback = mediaAutoplay ? [] : .all
        
        // UserAgent
        if let appName = applicationNameForUserAgent {
            configuration.applicationNameForUserAgent = appName
        }
        
        return configuration
    }
}
