//
//  YFColorPalette.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit
import YFExtensions

/// 颜色配置 - 自动适配暗黑模式
public struct YFColorPalette {
    
    // MARK: - 主色
    
    /// 主色
    public var primary: UIColor
    /// 主色 - 浅色
    public var primaryLight: UIColor
    /// 主色 - 深色
    public var primaryDark: UIColor
    
    // MARK: - 辅助色
    
    /// 辅助色
    public var secondary: UIColor
    /// 强调色
    public var accent: UIColor
    
    // MARK: - 功能色
    
    /// 成功
    public var success: UIColor
    /// 警告
    public var warning: UIColor
    /// 错误
    public var error: UIColor
    /// 信息
    public var info: UIColor
    
    // MARK: - 文字色
    
    /// 主要文字
    public var textPrimary: UIColor
    /// 次要文字
    public var textSecondary: UIColor
    /// 三级文字
    public var textTertiary: UIColor
    /// 禁用文字
    public var textDisabled: UIColor
    
    // MARK: - 背景色
    
    /// 主背景
    public var background: UIColor
    /// 次要背景
    public var backgroundSecondary: UIColor
    /// 表面色（卡片、导航栏等）
    public var surface: UIColor
    /// 次要表面色
    public var surfaceSecondary: UIColor
    
    // MARK: - 边框色
    
    /// 边框
    public var border: UIColor
    /// 分割线
    public var divider: UIColor
    
    // MARK: - 初始化（带默认动态颜色）
    
    public init(
        primary: UIColor = .dynamic(light: "#007AFF", dark: "#0A84FF"),
        primaryLight: UIColor = .dynamic(light: "#4DA3FF", dark: "#409CFF"),
        primaryDark: UIColor = .dynamic(light: "#0055B3", dark: "#0066CC"),
        secondary: UIColor = .dynamic(light: "#5856D6", dark: "#5E5CE6"),
        accent: UIColor = .dynamic(light: "#FF9500", dark: "#FF9F0A"),
        success: UIColor = .dynamic(light: "#34C759", dark: "#30D158"),
        warning: UIColor = .dynamic(light: "#FF9500", dark: "#FF9F0A"),
        error: UIColor = .dynamic(light: "#FF3B30", dark: "#FF453A"),
        info: UIColor = .dynamic(light: "#5AC8FA", dark: "#64D2FF"),
        textPrimary: UIColor = .dynamic(light: "#1A1A1A", dark: "#FFFFFF"),
        textSecondary: UIColor = .dynamic(light: "#666666", dark: "#A0A0A0"),
        textTertiary: UIColor = .dynamic(light: "#999999", dark: "#6E6E6E"),
        textDisabled: UIColor = .dynamic(light: "#CCCCCC", dark: "#4A4A4A"),
        background: UIColor = .dynamic(light: "#F5F5F5", dark: "#000000"),
        backgroundSecondary: UIColor = .dynamic(light: "#FFFFFF", dark: "#1C1C1E"),
        surface: UIColor = .dynamic(light: "#FFFFFF", dark: "#1C1C1E"),
        surfaceSecondary: UIColor = .dynamic(light: "#F8F8F8", dark: "#2C2C2E"),
        border: UIColor = .dynamic(light: "#E5E5E5", dark: "#3A3A3C"),
        divider: UIColor = .dynamic(light: "#EEEEEE", dark: "#2C2C2E")
    ) {
        self.primary = primary
        self.primaryLight = primaryLight
        self.primaryDark = primaryDark
        self.secondary = secondary
        self.accent = accent
        self.success = success
        self.warning = warning
        self.error = error
        self.info = info
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textTertiary = textTertiary
        self.textDisabled = textDisabled
        self.background = background
        self.backgroundSecondary = backgroundSecondary
        self.surface = surface
        self.surfaceSecondary = surfaceSecondary
        self.border = border
        self.divider = divider
    }
    
    /// 默认配色（自动适配暗黑模式）
    public static let `default` = YFColorPalette()
    
    /// 纯浅色配色（不跟随系统）
    public static let light = YFColorPalette(
        primary: UIColor(hex: "#007AFF"),
        primaryLight: UIColor(hex: "#4DA3FF"),
        primaryDark: UIColor(hex: "#0055B3"),
        secondary: UIColor(hex: "#5856D6"),
        accent: UIColor(hex: "#FF9500"),
        success: UIColor(hex: "#34C759"),
        warning: UIColor(hex: "#FF9500"),
        error: UIColor(hex: "#FF3B30"),
        info: UIColor(hex: "#5AC8FA"),
        textPrimary: UIColor(hex: "#1A1A1A"),
        textSecondary: UIColor(hex: "#666666"),
        textTertiary: UIColor(hex: "#999999"),
        textDisabled: UIColor(hex: "#CCCCCC"),
        background: UIColor(hex: "#F5F5F5"),
        backgroundSecondary: UIColor(hex: "#FFFFFF"),
        surface: UIColor(hex: "#FFFFFF"),
        surfaceSecondary: UIColor(hex: "#F8F8F8"),
        border: UIColor(hex: "#E5E5E5"),
        divider: UIColor(hex: "#EEEEEE")
    )
    
    /// 纯暗黑配色（不跟随系统）
    public static let dark = YFColorPalette(
        primary: UIColor(hex: "#0A84FF"),
        primaryLight: UIColor(hex: "#409CFF"),
        primaryDark: UIColor(hex: "#0066CC"),
        secondary: UIColor(hex: "#5E5CE6"),
        accent: UIColor(hex: "#FF9F0A"),
        success: UIColor(hex: "#30D158"),
        warning: UIColor(hex: "#FF9F0A"),
        error: UIColor(hex: "#FF453A"),
        info: UIColor(hex: "#64D2FF"),
        textPrimary: UIColor(hex: "#FFFFFF"),
        textSecondary: UIColor(hex: "#A0A0A0"),
        textTertiary: UIColor(hex: "#6E6E6E"),
        textDisabled: UIColor(hex: "#4A4A4A"),
        background: UIColor(hex: "#000000"),
        backgroundSecondary: UIColor(hex: "#1C1C1E"),
        surface: UIColor(hex: "#1C1C1E"),
        surfaceSecondary: UIColor(hex: "#2C2C2E"),
        border: UIColor(hex: "#3A3A3C"),
        divider: UIColor(hex: "#2C2C2E")
    )
}
