//
//  YFBaseViewController.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit
import SnapKit

/// 导航栏配置协议
public protocol YFNavigationConfigurable: AnyObject {
    /// 是否使用自定义导航栏（默认 true，隐藏系统导航栏）
    var useCustomNavigation: Bool { get }
}

/// 基础控制器 - 所有控制器的基类
/// 使用 YFContainerView 作为 view，自动管理导航栏
/// 子类添加视图时约束参考 safeAreaLayoutGuide，和系统导航栏使用方式一致
open class YFBaseViewController: UIViewController, YFNavigationConfigurable {
    
    // MARK: - Properties
    
    /// 当前主题
    public var theme: YFTheme {
        return YFThemeManager.shared.theme
    }
    
    /// 容器视图
    public var containerView: YFContainerView {
        return view as! YFContainerView
    }
    
    /// 自定义导航栏
    public var navigationBar: YFNavigationBar {
        return containerView.navigationBar
    }
    
    /// 是否使用自定义导航栏（默认 true）
    /// - true: 隐藏系统导航栏，显示自定义 YFNavigationBar
    /// - false: 显示系统导航栏，不显示自定义导航栏
    open var useCustomNavigation: Bool {
        return true
    }
    
    /// 状态栏样式（自动适配暗黑模式）
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if traitCollection.userInterfaceStyle == .dark {
            return .lightContent
        }
        return .darkContent
    }
    
    // MARK: - Lifecycle
    
    /// 重写 loadView，使用自定义容器视图
    open override func loadView() {
        let container = YFContainerView()
        container.showNavigationBar = useCustomNavigation
        container.backgroundColor = .themed(\.background)
        self.view = container
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupBindings()
        setupNavigationBarItems()
        setupNavigation()
        
        // 初始设置额外安全区域
        if useCustomNavigation {
            updateAdditionalSafeArea()
        }
    }
    
    /// 安全区域变化时更新（旋转、状态栏变化、通话中等）
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        if useCustomNavigation {
            updateAdditionalSafeArea()
        }
    }
    
    /// 暗黑模式切换时更新状态栏样式
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // 动态颜色自动适配，只需更新状态栏样式
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK: - Additional Safe Area
    
    /// 更新额外安全区域，让 safeAreaLayoutGuide.top 在导航栏下方
    private func updateAdditionalSafeArea() {
        // 延迟执行，确保导航栏已布局完成
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let navHeight = self.navigationBar.bounds.height
            if navHeight > 0 {
                let systemTopInset = self.view.safeAreaInsets.top - self.additionalSafeAreaInsets.top
                let extra = navHeight - systemTopInset
                if self.additionalSafeAreaInsets.top != extra {
                    self.additionalSafeAreaInsets.top = max(0, extra)
                }
            }
        }
    }
    
    // MARK: - Setup Navigation Bar
    
    private func setupNavigationBarItems() {
        guard useCustomNavigation else { return }
        
        // 非根控制器显示返回按钮
        if let nav = navigationController, nav.viewControllers.count > 1 {
            navigationBar.setBackButton(target: self, action: #selector(goBack))
        }
    }
    
    // MARK: - Setup Methods (子类重写)
    
    /// 设置 UI 元素
    open func setupUI() {}
    
    /// 设置约束
    open func setupConstraints() {}
    
    /// 设置绑定/事件
    open func setupBindings() {}
    
    /// 设置导航栏（标题、按钮等）
    open func setupNavigation() {}
    
    // MARK: - Navigation Helpers
    
    /// 设置导航栏标题
    public func setTitle(_ title: String) {
        if useCustomNavigation {
            navigationBar.title = title
        } else {
            self.title = title
        }
    }
    
    /// 返回上一页
    @objc open func goBack() {
        if let nav = navigationController {
            if nav.viewControllers.count > 1 {
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
    
    /// 关闭页面
    @objc open func closePage() {
        dismiss(animated: true)
    }
    
    /// 返回到根控制器
    open func popToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }
    
    /// 推入新页面
    open func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// 模态呈现页面
    open func presentVC(_ viewController: UIViewController, style: UIModalPresentationStyle = .automatic, animated: Bool = true) {
        viewController.modalPresentationStyle = style
        present(viewController, animated: animated)
    }
}
