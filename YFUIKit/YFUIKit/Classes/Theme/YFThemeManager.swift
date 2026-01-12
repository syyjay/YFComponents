//
//  YFThemeManager.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 主题管理器
public final class YFThemeManager {
    
    /// 单例
    public static let shared = YFThemeManager()
    
    /// 主题变更通知（切换主题风格时发送）
    public static let themeDidChangeNotification = Notification.Name("YFThemeDidChange")
    
    // MARK: - 属性
    
    /// 已注册的主题
    private var registeredThemes: [YFThemeType: YFTheme] = [.default: .default]
    
    /// 当前主题类型
    public private(set) var currentThemeType: YFThemeType = .default
    
    /// 当前外观模式
    public private(set) var currentAppearanceMode: YFAppearanceMode = .system
    
    /// 当前主题
    public var theme: YFTheme {
        return registeredThemes[currentThemeType] ?? .default
    }
    
    /// 所有已注册的主题类型
    public var allThemeTypes: [YFThemeType] {
        return Array(registeredThemes.keys)
    }
    
    private init() {}
    
    // MARK: - 主题注册
    
    /// 注册自定义主题
    /// - Parameters:
    ///   - theme: 主题配置
    ///   - type: 主题类型标识符
    public static func register(_ theme: YFTheme, for type: YFThemeType) {
        shared.registeredThemes[type] = theme
    }
    
    /// 批量注册主题
    /// - Parameter themes: 主题字典 [类型: 主题配置]
    public static func register(_ themes: [YFThemeType: YFTheme]) {
        for (type, theme) in themes {
            shared.registeredThemes[type] = theme
        }
    }
    
    /// 获取指定类型的主题
    public static func theme(for type: YFThemeType) -> YFTheme? {
        return shared.registeredThemes[type]
    }
    
    // MARK: - 主题切换
    
    /// 切换主题风格
    ///
    /// 切换主题后，使用 `.themed(\.xxx)` 设置的颜色会自动更新。
    /// 原理：通过强制触发 traitCollection 变化，让系统重新解析所有动态颜色。
    ///
    /// - Parameter type: 主题类型
    public static func setTheme(_ type: YFThemeType) {
        guard shared.currentThemeType != type else { return }
        shared.currentThemeType = type
        
        // 强制触发 traitCollection 变化，让系统重新解析所有 .themed() 颜色
        forceRefreshAllWindows()
        
        // 发送通知（用于需要额外处理的场景，如重建 UI）
        NotificationCenter.default.post(name: themeDidChangeNotification, object: type)
    }
    
    /// 强制刷新所有窗口的颜色
    ///
    /// 原理：切换一次外观模式再切回来，触发 traitCollectionDidChange
    /// 这会让系统重新调用所有动态颜色的 provider 闭包
    /// 使用 CATransaction 禁用动画，确保切换在同一帧完成，避免闪烁
    private static func forceRefreshAllWindows() {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        
        guard !windows.isEmpty else { return }
        
        // 保存当前的外观模式
        let currentMode = shared.currentAppearanceMode
        let currentStyle = currentMode.userInterfaceStyle
        
        // 临时切换到相反的外观模式
        let tempStyle: UIUserInterfaceStyle = (currentStyle == .dark) ? .light : .dark
        
        // 禁用动画，让切换瞬间完成，避免闪烁
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        windows.forEach { $0.overrideUserInterfaceStyle = tempStyle }
        
        // 强制布局，确保 traitCollectionDidChange 被触发
        windows.forEach { $0.layoutIfNeeded() }
        
        // 立即切回原来的外观模式
        windows.forEach { $0.overrideUserInterfaceStyle = currentStyle }
        
        CATransaction.commit()
    }
    
    /// 切换外观模式（浅色/暗黑）
    /// - Parameters:
    ///   - mode: 外观模式
    ///   - animated: 是否使用动画（默认 true）
    /// - Note: 动态颜色会自动适配，无需额外处理。只有 CGColor 需要在 traitCollectionDidChange 中更新。
    public static func setAppearanceMode(_ mode: YFAppearanceMode, animated: Bool = true) {
        guard shared.currentAppearanceMode != mode else { return }
        shared.currentAppearanceMode = mode
        
        // 设置所有 window 的界面风格（兼容 iPad 多窗口）
        let style = mode.userInterfaceStyle
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                windows.forEach { $0.overrideUserInterfaceStyle = style }
            }
        } else {
            windows.forEach { $0.overrideUserInterfaceStyle = style }
        }
    }
    
    // MARK: - 便捷方法
    
    /// 当前是否为暗黑模式
    public static var isDarkMode: Bool {
        switch shared.currentAppearanceMode {
        case .dark:
            return true
        case .light:
            return false
        case .system:
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
    }
}
