//
//  YFNavigationController.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 自定义导航控制器
open class YFNavigationController: UINavigationController {
    
    // MARK: - Properties
    
    /// 当前主题
    public var theme: YFTheme {
        return YFThemeManager.shared.theme
    }
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
        setupSystemNavigationBarAppearance()
    }
    
    // MARK: - Setup
    
    /// 设置系统导航栏外观（用于 useCustomNavigation = false 的页面）
    private func setupSystemNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .themed(\.surface)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.themed(\.textPrimary),
            .font: theme.typography.headline
        ]
        appearance.shadowColor = .themed(\.divider)
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = .themed(\.primary)
    }
    
    // MARK: - Override Push/Pop
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        // 非根控制器隐藏 TabBar
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}

// MARK: - UINavigationControllerDelegate

extension YFNavigationController: UINavigationControllerDelegate {
    
    public func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        // 根据 VC 的配置决定是否隐藏系统导航栏
        let useCustom = (viewController as? YFNavigationConfigurable)?.useCustomNavigation ?? true
        setNavigationBarHidden(useCustom, animated: animated)
        
        // 处理转场取消时的状态恢复
        if let coordinator = viewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { [weak self] context in
                if context.isCancelled {
                    if let fromVC = context.viewController(forKey: .from) as? YFNavigationConfigurable {
                        self?.setNavigationBarHidden(fromVC.useCustomNavigation, animated: false)
                    }
                }
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension YFNavigationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 根控制器不响应返回手势
        return viewControllers.count > 1
    }
}
