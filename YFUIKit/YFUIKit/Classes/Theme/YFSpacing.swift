//
//  YFSpacing.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 间距配置
public struct YFSpacing {
    
    /// 超小 - 4pt
    public var xs: CGFloat
    /// 小 - 8pt
    public var sm: CGFloat
    /// 中 - 16pt
    public var md: CGFloat
    /// 大 - 24pt
    public var lg: CGFloat
    /// 超大 - 32pt
    public var xl: CGFloat
    /// 特大 - 48pt
    public var xxl: CGFloat
    
    public init(
        xs: CGFloat = 4,
        sm: CGFloat = 8,
        md: CGFloat = 16,
        lg: CGFloat = 24,
        xl: CGFloat = 32,
        xxl: CGFloat = 48
    ) {
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
    }
    
    /// 默认间距配置
    public static let `default` = YFSpacing()
}

/// 圆角配置
public struct YFCornerRadius {
    
    /// 小圆角 - 4pt
    public var small: CGFloat
    /// 中圆角 - 8pt
    public var medium: CGFloat
    /// 大圆角 - 12pt
    public var large: CGFloat
    /// 超大圆角 - 16pt
    public var xl: CGFloat
    /// 全圆角 (胶囊形状)
    public var full: CGFloat
    
    public init(
        small: CGFloat = 4,
        medium: CGFloat = 8,
        large: CGFloat = 12,
        xl: CGFloat = 16,
        full: CGFloat = 9999
    ) {
        self.small = small
        self.medium = medium
        self.large = large
        self.xl = xl
        self.full = full
    }
    
    /// 默认圆角配置
    public static let `default` = YFCornerRadius()
}

