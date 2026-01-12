//
//  YFCollectionView.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 自定义 CollectionView - 内置空状态
///
/// 默认使用 `.themed()` 颜色，主题切换时自动更新
open class YFCollectionView: UICollectionView {
    
    public var theme: YFTheme { YFThemeManager.shared.theme }
    
    /// 空状态视图
    public lazy var emptyView: YFEmptyView = {
        let view = YFEmptyView(type: .noData)
        view.isHidden = true
        return view
    }()
    
    // MARK: - Init
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    /// 流式布局便捷初始化
    public convenience init(
        direction: UICollectionView.ScrollDirection = .vertical,
        itemSize: CGSize = CGSize(width: 100, height: 100),
        spacing: CGFloat = 10
    ) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = direction
        layout.itemSize = itemSize
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.init(frame: .zero, collectionViewLayout: layout)
    }
    
    private func setup() {
        backgroundColor = .themed(\.background)
        backgroundView = emptyView
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
    
    public func updateEmpty() {
        var count = 0
        for section in 0..<numberOfSections {
            count += numberOfItems(inSection: section)
        }
        emptyView.isHidden = count > 0
    }
    
    open override func reloadData() {
        super.reloadData()
        DispatchQueue.main.async { self.updateEmpty() }
    }
}
