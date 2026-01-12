//
//  YFLabel.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 自定义 Label - 支持主题和链式调用
///
/// 默认使用 `.themed()` 颜色，主题切换时自动更新
open class YFLabel: UILabel {
    
    public var theme: YFTheme { YFThemeManager.shared.theme }
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public convenience init(_ text: String? = nil) {
        self.init(frame: .zero)
        self.text = text
    }
    
    private func setup() {
        font = theme.typography.body
        textColor = .themed(\.textPrimary)
    }
    
    // MARK: - 链式调用
    
    @discardableResult
    public func text(_ text: String?) -> Self {
        self.text = text
        return self
    }
    
    @discardableResult
    public func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
    
    @discardableResult
    public func color(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    @discardableResult
    public func lines(_ lines: Int) -> Self {
        self.numberOfLines = lines
        return self
    }
    
    @discardableResult
    public func align(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }
    
    // MARK: - 快捷样式
    
    /// 标题样式
    @discardableResult
    public func asTitle() -> Self {
        font = theme.typography.headline
        textColor = .themed(\.textPrimary)
        return self
    }
    
    /// 正文样式
    @discardableResult
    public func asBody() -> Self {
        font = theme.typography.body
        textColor = .themed(\.textPrimary)
        return self
    }
    
    /// 说明文字样式
    @discardableResult
    public func asCaption() -> Self {
        font = theme.typography.caption1
        textColor = .themed(\.textSecondary)
        return self
    }
    
    /// 主题色
    @discardableResult
    public func asPrimary() -> Self {
        textColor = .themed(\.primary)
        return self
    }
}
