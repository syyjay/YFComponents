//
//  YFTheme.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 主题协议
public protocol YFThemeProtocol {
    var colors: YFColorPalette { get }
    var typography: YFTypography { get }
    var spacing: YFSpacing { get }
    var cornerRadius: YFCornerRadius { get }
}

/// 主题类型标识符
/// 使用结构体而非枚举，支持业务层扩展自定义主题
public struct YFThemeType: RawRepresentable, Hashable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// 默认主题
    public static let `default` = YFThemeType(rawValue: "default")
}

/// 外观模式
public enum YFAppearanceMode: String, CaseIterable {
    case system = "跟随系统"
    case light = "浅色模式"
    case dark = "暗黑模式"
    
    /// 获取对应的界面风格
    public var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// 主题实现
public struct YFTheme: YFThemeProtocol {
    public var colors: YFColorPalette
    public var typography: YFTypography
    public var spacing: YFSpacing
    public var cornerRadius: YFCornerRadius
    
    public init(
        colors: YFColorPalette = .default,
        typography: YFTypography = .default,
        spacing: YFSpacing = .default,
        cornerRadius: YFCornerRadius = .default
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.cornerRadius = cornerRadius
    }
    
    /// 默认主题
    public static let `default` = YFTheme()
}
