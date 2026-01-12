//
//  YFTableView.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 自定义 TableView - 内置空状态
///
/// 默认使用 `.themed()` 颜色，主题切换时自动更新
open class YFTableView: UITableView {
    
    public var theme: YFTheme { YFThemeManager.shared.theme }
    
    /// 空状态视图
    public lazy var emptyView: YFEmptyView = {
        let view = YFEmptyView(type: .noData)
        view.isHidden = true
        return view
    }()
    
    // MARK: - Init
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public convenience init(_ style: UITableView.Style = .plain) {
        self.init(frame: .zero, style: style)
    }
    
    private func setup() {
        backgroundColor = .themed(\.background)
        separatorColor = .themed(\.divider)
        tableFooterView = UIView()
        backgroundView = emptyView
        
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
        }
    }
    
    // MARK: - Empty State
    
    /// 设置空状态（简化版）
    public func setEmpty(icon: String = "tray", title: String = "暂无数据", desc: String? = nil) {
        _ = emptyView.icon(icon).title(title).desc(desc)
    }
    
    /// 设置空状态（带操作按钮）
    public func setEmpty(icon: String = "tray", title: String = "暂无数据", action: String, handler: @escaping () -> Void) {
        _ = emptyView.icon(icon).title(title).action(action, handler: handler)
    }
    
    /// 更新空状态显示
    public func updateEmpty() {
        var count = 0
        for section in 0..<numberOfSections {
            count += numberOfRows(inSection: section)
        }
        emptyView.isHidden = count > 0
    }
    
    open override func reloadData() {
        super.reloadData()
        DispatchQueue.main.async { self.updateEmpty() }
    }
}
