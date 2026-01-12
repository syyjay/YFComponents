//
//  YFContainerView.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit
import SnapKit

/// 自定义容器视图
/// 自动管理导航栏层级，确保导航栏始终在最上层
public class YFContainerView: UIView {
    
    // MARK: - Properties
    
    /// 当前主题
    public var theme: YFTheme {
        return YFUIKit.theme
    }
    
    /// 自定义导航栏
    public lazy var navigationBar: YFNavigationBar = {
        let bar = YFNavigationBar()
        return bar
    }()
    
    /// 是否显示导航栏
    public var showNavigationBar: Bool = true {
        didSet {
            navigationBar.isHidden = !showNavigationBar
        }
    }
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupNavigationBar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        super.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
    }
    
    // MARK: - 确保导航栏始终在最上层
    
    public override func addSubview(_ view: UIView) {
        super.addSubview(view)
        if view !== navigationBar && showNavigationBar {
            bringSubviewToFront(navigationBar)
        }
    }
    
    public override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        if showNavigationBar {
            bringSubviewToFront(navigationBar)
        }
    }
    
    public override func insertSubview(_ view: UIView, aboveSubview siblingSubview: UIView) {
        super.insertSubview(view, aboveSubview: siblingSubview)
        if showNavigationBar {
            bringSubviewToFront(navigationBar)
        }
    }
    
    public override func insertSubview(_ view: UIView, belowSubview siblingSubview: UIView) {
        super.insertSubview(view, belowSubview: siblingSubview)
        if showNavigationBar {
            bringSubviewToFront(navigationBar)
        }
    }
}

