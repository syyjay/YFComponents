//
//  YFTabBar.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit
import SnapKit

/// 自定义 TabBar - 继承系统 UITabBar
open class YFTabBar: UITabBar {
    
    // MARK: - Properties
    
    /// 当前主题
    public var theme: YFTheme {
        return YFThemeManager.shared.theme
    }
    
    /// 中间凸起按钮（可选）
    public var centerButton: UIButton?
    
    /// 中间按钮点击回调
    public var onCenterButtonTap: (() -> Void)?
    
    /// 顶部分割线
    private lazy var topSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .themed(\.divider)
        return view
    }()
    
    /// 背景毛玻璃效果
    private lazy var blurEffectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: blur)
        return view
    }()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // 设置背景
        backgroundColor = .themed(\.surface)
        
        // 移除默认分割线
        shadowImage = UIImage()
        backgroundImage = UIImage()
        
        // 添加自定义分割线
        addSubview(topSeparator)
        topSeparator.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        // 设置选中/未选中颜色
        tintColor = .themed(\.primary)
        unselectedItemTintColor = .themed(\.textTertiary)
    }
    
    // MARK: - Center Button
    
    /// 添加中间凸起按钮
    public func addCenterButton(
        image: UIImage?,
        size: CGFloat = 56,
        backgroundColor: UIColor? = nil,
        offset: CGFloat = -20
    ) {
        // 移除旧按钮
        centerButton?.removeFromSuperview()
        
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.backgroundColor = backgroundColor ?? .themed(\.primary)
        button.tintColor = .white
        button.layer.cornerRadius = size / 2
        button.layer.shadowColor = UIColor.themed(\.primary).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
        
        addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(offset)
            make.size.equalTo(size)
        }
        
        centerButton = button
    }
    
    @objc private func centerButtonTapped() {
        onCenterButtonTap?()
    }
    
    // MARK: - Hit Test
    
    /// 扩大中间按钮的点击区域
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let centerButton = centerButton, !centerButton.isHidden {
            let buttonPoint = convert(point, to: centerButton)
            if centerButton.bounds.contains(buttonPoint) {
                return centerButton
            }
        }
        return super.hitTest(point, with: event)
    }
    
    // MARK: - Appearance
    
    /// 设置背景颜色
    public func setBackgroundColor(_ color: UIColor) {
        backgroundColor = color
    }
    
    /// 设置毛玻璃效果
    public func setBlurEffect(enabled: Bool, style: UIBlurEffect.Style = .systemMaterial) {
        blurEffectView.removeFromSuperview()
        
        if enabled {
            blurEffectView.effect = UIBlurEffect(style: style)
            insertSubview(blurEffectView, at: 0)
            blurEffectView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            backgroundColor = .clear
        } else {
            backgroundColor = .themed(\.surface)
        }
    }
    
    /// 设置分割线颜色
    public func setSeparatorColor(_ color: UIColor) {
        topSeparator.backgroundColor = color
    }
    
    /// 隐藏分割线
    public func hideSeparator(_ hidden: Bool) {
        topSeparator.isHidden = hidden
    }
    
    // MARK: - Dark Mode
    
    /// 暗黑模式切换时更新 CGColor（动态颜色不支持 CGColor）
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // 只需更新 CGColor，其他动态颜色自动适配
            centerButton?.layer.shadowColor = UIColor.themed(\.primary).resolvedColor(with: traitCollection).cgColor
        }
    }
}

