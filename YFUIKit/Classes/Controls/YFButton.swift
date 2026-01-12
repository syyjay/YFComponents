//
//  YFButton.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 按钮样式
public enum YFButtonStyle {
    case primary       // 主按钮（填充背景）
    case secondary     // 次按钮（边框）
    case text          // 文字按钮
    case destructive   // 危险按钮（红色）
}

/// 自定义 Button - 支持主题和链式调用
///
/// 默认使用 `.themed()` 颜色，主题切换时自动更新
open class YFButton: UIButton {
    
    public var theme: YFTheme { YFThemeManager.shared.theme }
    
    private var tapAction: (() -> Void)?
    private var currentStyle: YFButtonStyle?
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public convenience init(_ title: String) {
        self.init(frame: .zero)
        setTitle(title, for: .normal)
    }
    
    public convenience init(image: UIImage?) {
        self.init(frame: .zero)
        setImage(image, for: .normal)
    }
    
    private func setup() {
        titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        setTitleColor(.themed(\.primary), for: .normal)
        tintColor = .themed(\.primary)
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    @objc private func handleTap() {
        tapAction?()
    }
    
    // MARK: - 链式调用
    
    @discardableResult
    public func title(_ title: String) -> Self {
        setTitle(title, for: .normal)
        return self
    }
    
    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        setImage(image, for: .normal)
        return self
    }
    
    @discardableResult
    public func font(_ font: UIFont) -> Self {
        titleLabel?.font = font
        return self
    }
    
    @discardableResult
    public func color(_ color: UIColor) -> Self {
        setTitleColor(color, for: .normal)
        tintColor = color
        return self
    }
    
    @discardableResult
    public func background(_ color: UIColor) -> Self {
        backgroundColor = color
        return self
    }
    
    @discardableResult
    public func onPressed(_ action: @escaping () -> Void) -> Self {
        tapAction = action
        return self
    }
    
    // MARK: - 样式
    
    @discardableResult
    public func style(_ style: YFButtonStyle) -> Self {
        currentStyle = style
        applyStyle(style)
        return self
    }
    
    private func applyStyle(_ style: YFButtonStyle) {
        switch style {
        case .primary:
            backgroundColor = .themed(\.primary)
            setTitleColor(.white, for: .normal)
            tintColor = .white
            layer.cornerRadius = 8
            layer.borderWidth = 0
            contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
            
        case .secondary:
            backgroundColor = .clear
            setTitleColor(.themed(\.primary), for: .normal)
            tintColor = .themed(\.primary)
            layer.cornerRadius = 8
            layer.borderWidth = 1
            layer.borderColor = UIColor.themed(\.primary).cgColor
            contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
            
        case .text:
            backgroundColor = .clear
            setTitleColor(.themed(\.primary), for: .normal)
            tintColor = .themed(\.primary)
            layer.borderWidth = 0
            
        case .destructive:
            backgroundColor = .themed(\.error)
            setTitleColor(.white, for: .normal)
            tintColor = .white
            layer.cornerRadius = 8
            layer.borderWidth = 0
            contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        }
    }
    
    // MARK: - Trait Collection
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // 更新 CGColor（因为 layer 属性不支持动态颜色）
            if let style = currentStyle {
                if style == .secondary {
                    layer.borderColor = UIColor.themed(\.primary).resolvedColor(with: traitCollection).cgColor
                }
            }
        }
    }
}
