//
//  YFImageView.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 自定义 ImageView - 支持主题和链式调用
open class YFImageView: UIImageView {
    
    public var theme: YFTheme { YFUIKit.theme }
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public override init(image: UIImage?) {
        super.init(image: image)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public convenience init(_ image: UIImage? = nil) {
        self.init(frame: .zero)
        self.image = image
    }
    
    public convenience init(systemName: String) {
        self.init(frame: .zero)
        self.image = UIImage(systemName: systemName)
    }
    
    private func setup() {
        contentMode = .scaleAspectFill
        clipsToBounds = true
    }
    
    // MARK: - 链式调用
    
    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }
    
    @discardableResult
    public func mode(_ mode: UIView.ContentMode) -> Self {
        self.contentMode = mode
        return self
    }
    
    @discardableResult
    public func circle() -> Self {
        layer.masksToBounds = true
        // 需要在布局后设置
        return self
    }
    
    @discardableResult
    public func border(_ width: CGFloat, color: UIColor) -> Self {
        layer.borderWidth = width
        borderColor = color
        layer.borderColor = color.cgColor
        return self
    }
    
    // MARK: - Dark Mode
    
    private var borderColor: UIColor?
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if layer.borderWidth > 0, let color = borderColor {
                layer.borderColor = color.cgColor
            }
        }
    }
    
    @discardableResult
    public func tint(_ color: UIColor) -> Self {
        tintColor = color
        return self
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // 如果设置了 circle，自动计算圆角
        if layer.masksToBounds && layer.cornerRadius == 0 {
            // 检查是否需要圆形
        }
    }
    
    /// 设置为圆形（需要在约束确定后调用）
    public func makeCircle() {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
}
