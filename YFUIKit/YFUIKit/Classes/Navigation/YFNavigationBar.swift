//
//  YFNavigationBar.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit
import SnapKit

/// 自定义导航栏
open class YFNavigationBar: YFBaseView {
    
    // MARK: - UI Components
    
    /// 背景视图
    public lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .themed(\.surface)
        return view
    }()
    
    /// 底部分割线
    public lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .themed(\.divider)
        return view
    }()
    
    /// 左侧按钮容器
    public lazy var leftStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    /// 右侧按钮容器
    public lazy var rightStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    /// 标题标签
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = theme.typography.headline
        label.textColor = .themed(\.textPrimary)
        label.textAlignment = .center
        return label
    }()
    
    /// 自定义标题视图
    public var titleView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let titleView = titleView {
                contentView.addSubview(titleView)
                titleView.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                }
                titleLabel.isHidden = true
            } else {
                titleLabel.isHidden = false
            }
        }
    }
    
    /// 内容视图（不包含状态栏高度）
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - Properties
    
    /// 导航栏高度（不含状态栏）
    public var barHeight: CGFloat = 44
    
    /// 是否显示分割线
    public var showSeparator: Bool = true {
        didSet { separatorView.isHidden = !showSeparator }
    }
    
    /// 是否透明背景
    public var isTransparent: Bool = false {
        didSet { updateTransparency() }
    }
    
    /// 标题
    public var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    // MARK: - Setup
    
    open override func setupUI() {
        addSubview(backgroundView)
        addSubview(contentView)
        addSubview(separatorView)
        
        contentView.addSubview(leftStackView)
        contentView.addSubview(rightStackView)
        contentView.addSubview(titleLabel)
    }
    
    open override func setupConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(barHeight)
        }
        
        separatorView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        leftStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        rightStackView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualTo(leftStackView.snp.right).offset(16)
            make.right.lessThanOrEqualTo(rightStackView.snp.left).offset(-16)
        }
    }
    
    /// 固有尺寸 - 让导航栏自动计算高度
    /// 返回 (状态栏高度 + barHeight)，这样：
    /// 1. 约束时无需手动设置高度，只需设置 top/left/right
    /// 2. 背景可以延伸到状态栏区域，视觉统一
    /// 3. 适配不同设备（刘海屏/非刘海屏）和状态栏显隐变化
    open override var intrinsicContentSize: CGSize {
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 44
        return CGSize(width: UIView.noIntrinsicMetric, height: statusBarHeight + barHeight)
    }
    
    /// 安全区域变化时重新计算高度（如屏幕旋转、状态栏显隐）
    open override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Private Methods
    
    private func updateTransparency() {
        backgroundView.backgroundColor = isTransparent ? .clear : .themed(\.surface)
        separatorView.isHidden = isTransparent || !showSeparator
    }
    
    // MARK: - Public Methods
    
    /// 设置返回按钮
    @discardableResult
    public func setBackButton(
        image: UIImage? = nil,
        target: Any?,
        action: Selector
    ) -> UIButton {
        let btn = createButton(
            image: image ?? UIImage(systemName: "chevron.left"),
            target: target,
            action: action
        )
        leftStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        leftStackView.addArrangedSubview(btn)
        return btn
    }
    
    /// 设置关闭按钮
    @discardableResult
    public func setCloseButton(target: Any?, action: Selector) -> UIButton {
        return setBackButton(
            image: UIImage(systemName: "xmark"),
            target: target,
            action: action
        )
    }
    
    /// 添加左侧按钮
    @discardableResult
    public func addLeftButton(
        image: UIImage?,
        target: Any?,
        action: Selector
    ) -> UIButton {
        let btn = createButton(image: image, target: target, action: action)
        leftStackView.addArrangedSubview(btn)
        return btn
    }
    
    /// 添加左侧文字按钮
    @discardableResult
    public func addLeftButton(
        title: String,
        target: Any?,
        action: Selector
    ) -> UIButton {
        let btn = createButton(title: title, target: target, action: action)
        leftStackView.addArrangedSubview(btn)
        return btn
    }
    
    /// 添加右侧按钮
    @discardableResult
    public func addRightButton(
        image: UIImage?,
        target: Any?,
        action: Selector
    ) -> UIButton {
        let btn = createButton(image: image, target: target, action: action)
        rightStackView.addArrangedSubview(btn)
        return btn
    }
    
    /// 添加右侧文字按钮
    @discardableResult
    public func addRightButton(
        title: String,
        target: Any?,
        action: Selector
    ) -> UIButton {
        let btn = createButton(title: title, target: target, action: action)
        rightStackView.addArrangedSubview(btn)
        return btn
    }
    
    /// 清空左侧按钮
    public func clearLeftButtons() {
        leftStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 清空右侧按钮
    public func clearRightButtons() {
        rightStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    // MARK: - Button Factory
    
    private func createButton(
        image: UIImage? = nil,
        title: String? = nil,
        target: Any?,
        action: Selector
    ) -> UIButton {
        let btn = UIButton(type: .system)
        btn.tintColor = .themed(\.textPrimary)
        
        if let image = image {
            btn.setImage(image, for: .normal)
        }
        
        if let title = title {
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.font = theme.typography.body
            btn.setTitleColor(.themed(\.primary), for: .normal)
        }
        
        btn.addTarget(target, action: action, for: .touchUpInside)
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        return btn
    }
}
