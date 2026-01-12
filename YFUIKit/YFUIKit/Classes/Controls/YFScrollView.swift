//
//  YFScrollView.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit
import SnapKit

/// 自定义 ScrollView - 内置 contentView
///
/// 默认使用 `.themed()` 颜色，主题切换时自动更新
open class YFScrollView: UIScrollView {
    
    public var theme: YFTheme { YFThemeManager.shared.theme }
    
    /// 内容视图
    public lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .themed(\.background)
        showsHorizontalScrollIndicator = false
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    // MARK: - 便捷方法
    
    public func scrollToTop(animated: Bool = true) {
        setContentOffset(.zero, animated: animated)
    }
    
    public func scrollToBottom(animated: Bool = true) {
        let offset = CGPoint(x: 0, y: max(0, contentSize.height - bounds.height + contentInset.bottom))
        setContentOffset(offset, animated: animated)
    }
}
