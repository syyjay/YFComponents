//
//  YFUIKit.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// YFUIKit 全局配置入口
public final class YFUIKit {
    
    /// 单例
    public static let shared = YFUIKit()
    
    /// 当前版本
    public static let version = "1.0.0"
    
    /// 资源 Bundle
    public static var bundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        let bundlePath = Bundle(for: YFUIKit.self).path(forResource: "YFUIKit", ofType: "bundle")
        return Bundle(path: bundlePath ?? "") ?? Bundle.main
        #endif
    }
    
    /// 全局配置
    public var config = YFUIKitConfig()
    
    private init() {}
    
    /// 初始化配置
    /// - Parameter configuration: 配置闭包
    public static func configure(_ configuration: (YFUIKit) -> Void) {
        configuration(shared)
    }
    
    // MARK: - 便捷访问（转发到 YFThemeManager）
    
    /// 当前主题
    public static var theme: YFTheme {
        return YFThemeManager.shared.theme
    }
    
    /// 当前主题类型
    public static var currentThemeType: YFThemeType {
        return YFThemeManager.shared.currentThemeType
    }
    
    /// 当前外观模式
    public static var currentAppearanceMode: YFAppearanceMode {
        return YFThemeManager.shared.currentAppearanceMode
    }
    
    /// 当前是否为暗黑模式
    public static var isDarkMode: Bool {
        return YFThemeManager.isDarkMode
    }
}

/// 全局配置项
public struct YFUIKitConfig {
    /// 默认动画时长
    public var animationDuration: TimeInterval = 0.25
    
    /// 默认圆角大小
    public var cornerRadius: CGFloat = 8
    
    /// 是否显示调试信息
    public var isDebugEnabled: Bool = false
    
    public init() {}
}
