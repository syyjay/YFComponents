//
//  YFBaseView.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 基础视图 - 所有自定义视图的基类
open class YFBaseView: UIView {
    
    // MARK: - Properties
    
    /// 当前主题
    public var theme: YFTheme {
        return YFThemeManager.shared.theme
    }
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupBindings()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupBindings()
    }
    
    // MARK: - Setup Methods (子类重写)
    
    /// 设置 UI 元素
    open func setupUI() {}
    
    /// 设置约束
    open func setupConstraints() {}
    
    /// 设置绑定/事件
    open func setupBindings() {}
    
    /// 主题变更时调用（子类重写以更新颜色）
    open func themeDidChange() {}
    
    // MARK: - Dark Mode
    
    /// 暗黑模式切换时更新
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            themeDidChange()
        }
    }
}

