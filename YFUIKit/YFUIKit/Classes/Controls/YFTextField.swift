//
//  YFTextField.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 自定义 TextField - 支持主题和链式调用
///
/// 默认使用 `.themed()` 颜色，主题切换时自动更新
open class YFTextField: UITextField {
    
    public var theme: YFTheme { YFThemeManager.shared.theme }
    
    /// 左右内边距
    public var padding: CGFloat = 12
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public convenience init(_ placeholder: String? = nil) {
        self.init(frame: .zero)
        self.placeholder = placeholder
    }
    
    private func setup() {
        font = theme.typography.body
        textColor = .themed(\.textPrimary)
        tintColor = .themed(\.primary)
        backgroundColor = .themed(\.backgroundSecondary)
        layer.cornerRadius = 8
        
        // 设置占位符颜色
        if let placeholder = placeholder {
            attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: UIColor.themed(\.textTertiary)]
            )
        }
    }
    
    // MARK: - Padding
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: padding, dy: 0)
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: padding, dy: 0)
    }
    
    open override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 44)
    }
    
    // MARK: - 链式调用
    
    @discardableResult
    public func placeholder(_ text: String) -> Self {
        placeholder = text
        attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [.foregroundColor: UIColor.themed(\.textTertiary)]
        )
        return self
    }
    
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
    public func keyboard(_ type: UIKeyboardType) -> Self {
        keyboardType = type
        return self
    }
    
    @discardableResult
    public func secure(_ isSecure: Bool = true) -> Self {
        isSecureTextEntry = isSecure
        return self
    }
    
    @discardableResult
    public func bordered(_ color: UIColor? = nil) -> Self {
        backgroundColor = .clear
        layer.borderWidth = 1
        borderColor = color ?? .themed(\.divider)
        layer.borderColor = borderColor?.cgColor
        return self
    }
    
    // MARK: - Dark Mode
    
    private var borderColor: UIColor?
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // CGColor 不支持动态颜色，需要手动更新
            if layer.borderWidth > 0, let color = borderColor {
                layer.borderColor = color.cgColor
            }
        }
    }
}
