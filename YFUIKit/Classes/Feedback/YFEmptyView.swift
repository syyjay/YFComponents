//
//  YFEmptyView.swift
//  YFUIKit
//
//  空状态视图
//

import UIKit
import SnapKit

// MARK: - 预设类型

/// 空状态类型
public enum YFEmptyType {
    case noData
    case noNetwork
    case noResult
    case error
    case custom
    
    var icon: String {
        switch self {
        case .noData: return "tray"
        case .noNetwork: return "wifi.slash"
        case .noResult: return "magnifyingglass"
        case .error: return "exclamationmark.triangle"
        case .custom: return "questionmark.circle"
        }
    }
    
    var title: String {
        switch self {
        case .noData: return "暂无数据"
        case .noNetwork: return "网络不可用"
        case .noResult: return "未找到结果"
        case .error: return "加载失败"
        case .custom: return ""
        }
    }
}

// MARK: - YFEmptyView

/// 空状态视图
public class YFEmptyView: UIView {
    
    // MARK: - Properties
    
    private var theme: YFTheme { YFThemeManager.shared.theme }
    private var actionHandler: (() -> Void)?
    
    // MARK: - UI
    
    private lazy var contentStack = YFStackView.vertical(spacing: 16, alignment: .center)
    
    private lazy var iconView: YFImageView = {
        let iv = YFImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .themed(\.textTertiary)
        return iv
    }()
    
    private lazy var titleLabel = YFLabel()
        .font(.systemFont(ofSize: 16, weight: .medium))
        .color(.themed(\.textPrimary))
        .align(.center)
    
    private lazy var descLabel = YFLabel()
        .font(.systemFont(ofSize: 14))
        .color(.themed(\.textSecondary))
        .align(.center)
        .lines(0)
    
    private lazy var actionButton = YFButton()
        .style(.primary)
        .onPressed { [weak self] in self?.actionHandler?() }
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    public convenience init(type: YFEmptyType = .noData) {
        self.init(frame: .zero)
        configure(type: type)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(contentStack)
        contentStack.addViews(iconView, titleLabel, descLabel, actionButton)
        
        contentStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(40)
        }
        
        iconView.snp.makeConstraints { make in
            make.size.equalTo(60)
        }
        
        actionButton.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(120)
            make.height.equalTo(40)
        }
        
        // 默认隐藏
        descLabel.isHidden = true
        actionButton.isHidden = true
    }
    
    // MARK: - Configure
    
    private func configure(type: YFEmptyType) {
        iconView.image = UIImage(systemName: type.icon)
        titleLabel.text = type.title
    }
    
    // MARK: - 链式调用
    
    /// 设置图标（系统图标名）
    @discardableResult
    public func icon(_ systemName: String) -> Self {
        iconView.image = UIImage(systemName: systemName)
        return self
    }
    
    /// 设置图片
    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        iconView.image = image
        return self
    }
    
    /// 设置图标颜色
    @discardableResult
    public func iconColor(_ color: UIColor) -> Self {
        iconView.tintColor = color
        return self
    }
    
    /// 设置图标尺寸
    @discardableResult
    public func iconSize(_ size: CGFloat) -> Self {
        iconView.snp.updateConstraints { make in
            make.size.equalTo(size)
        }
        return self
    }
    
    /// 设置标题
    @discardableResult
    public func title(_ text: String?) -> Self {
        titleLabel.text = text
        titleLabel.isHidden = text?.isEmpty ?? true
        return self
    }
    
    /// 设置描述
    @discardableResult
    public func desc(_ text: String?) -> Self {
        descLabel.text = text
        descLabel.isHidden = text?.isEmpty ?? true
        return self
    }
    
    /// 设置操作按钮
    @discardableResult
    public func action(_ title: String, handler: @escaping () -> Void) -> Self {
        actionButton.title(title)
        actionButton.isHidden = false
        actionHandler = handler
        return self
    }
    
    /// 隐藏图标
    @discardableResult
    public func hideIcon() -> Self {
        iconView.isHidden = true
        return self
    }
}

// MARK: - 便捷工厂方法

public extension YFEmptyView {
    
    /// 无数据
    static func noData(_ title: String = "暂无数据", desc: String? = nil) -> YFEmptyView {
        YFEmptyView(type: .noData).title(title).desc(desc)
    }
    
    /// 网络错误
    static func noNetwork(_ title: String = "网络不可用", action: String = "重试", handler: @escaping () -> Void) -> YFEmptyView {
        YFEmptyView(type: .noNetwork).title(title).desc("请检查网络连接").action(action, handler: handler)
    }
    
    /// 搜索无结果
    static func noResult(_ keyword: String? = nil) -> YFEmptyView {
        let title = keyword != nil ? "未找到「\(keyword!)」" : "未找到结果"
        return YFEmptyView(type: .noResult).title(title).desc("换个关键词试试")
    }
    
    /// 加载失败
    static func error(_ title: String = "加载失败", action: String = "重试", handler: @escaping () -> Void) -> YFEmptyView {
        YFEmptyView(type: .error).title(title).action(action, handler: handler)
    }
}

// MARK: - UIView Extension

public extension UIView {
    
    private static var emptyViewKey: UInt8 = 0
    
    private var yf_emptyView: YFEmptyView? {
        get { objc_getAssociatedObject(self, &UIView.emptyViewKey) as? YFEmptyView }
        set { objc_setAssociatedObject(self, &UIView.emptyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 显示空状态
    func yf_showEmpty(_ emptyView: YFEmptyView) {
        yf_hideEmpty()
        yf_emptyView = emptyView
        addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 显示空状态（便捷方法）
    func yf_showEmpty(
        icon: String = "tray",
        title: String = "暂无数据",
        desc: String? = nil,
        action: String? = nil,
        handler: (() -> Void)? = nil
    ) {
        let empty = YFEmptyView()
            .icon(icon)
            .title(title)
            .desc(desc)
        
        if let actionTitle = action, let actionHandler = handler {
            empty.action(actionTitle, handler: actionHandler)
        }
        
        yf_showEmpty(empty)
    }
    
    /// 隐藏空状态
    func yf_hideEmpty() {
        yf_emptyView?.removeFromSuperview()
        yf_emptyView = nil
    }
}
