//
//  YFStackView.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 自定义 StackView - 便捷初始化
open class YFStackView: UIStackView {
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public convenience init(
        _ axis: NSLayoutConstraint.Axis = .vertical,
        spacing: CGFloat = 0,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill
    ) {
        self.init(frame: .zero)
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
    }
    
    // MARK: - 工厂方法
    
    public static func horizontal(spacing: CGFloat = 0, alignment: Alignment = .fill, distribution: Distribution = .fill) -> YFStackView {
        YFStackView(.horizontal, spacing: spacing, alignment: alignment, distribution: distribution)
    }
    
    public static func vertical(spacing: CGFloat = 0, alignment: Alignment = .fill, distribution: Distribution = .fill) -> YFStackView {
        YFStackView(.vertical, spacing: spacing, alignment: alignment, distribution: distribution)
    }
    
    // MARK: - 便捷方法
    
    @discardableResult
    public func addViews(_ views: UIView...) -> Self {
        views.forEach { addArrangedSubview($0) }
        return self
    }
    
    @discardableResult
    public func addViews(_ views: [UIView]) -> Self {
        views.forEach { addArrangedSubview($0) }
        return self
    }
    
    public func removeAll() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 添加间距
    @discardableResult
    public func addSpace(_ space: CGFloat) -> Self {
        let spacer = UIView()
        if axis == .vertical {
            spacer.snp.makeConstraints { $0.height.equalTo(space) }
        } else {
            spacer.snp.makeConstraints { $0.width.equalTo(space) }
        }
        addArrangedSubview(spacer)
        return self
    }
    
    /// 添加弹性空间
    @discardableResult
    public func addFlexSpace() -> Self {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: axis)
        addArrangedSubview(spacer)
        return self
    }
}
