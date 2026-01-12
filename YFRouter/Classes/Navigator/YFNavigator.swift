//
//  YFNavigator.swift
//  YFRouter
//
//  导航器 - 封装导航操作
//

import UIKit

/// 导航方式
public enum YFNavigateType {
    /// Push（需要在 NavigationController 中）
    case push
    /// Present
    case present
    /// Present 全屏模式
    case presentFullScreen
    /// Present 并包装在 NavigationController 中
    case presentWithNav
}

/// 导航器
/// 封装常用的页面导航操作
public class YFNavigator {
    
    // MARK: - 获取关键视图
    
    /// 获取 keyWindow
    public static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    /// 获取当前最顶层的 ViewController
    public static var topViewController: UIViewController? {
        guard let rootVC = keyWindow?.rootViewController else { return nil }
        return findTopViewController(from: rootVC)
    }
    
    /// 获取当前的 NavigationController
    public static var currentNavigationController: UINavigationController? {
        if let nav = topViewController?.navigationController {
            return nav
        }
        if let nav = topViewController as? UINavigationController {
            return nav
        }
        return nil
    }
    
    // MARK: - 导航操作
    
    /// Push 页面
    /// - Returns: 是否成功
    @discardableResult
    public static func push(_ viewController: UIViewController, animated: Bool = true) -> Bool {
        guard let nav = currentNavigationController else { return false }
        nav.pushViewController(viewController, animated: animated)
        return true
    }
    
    /// Present 页面
    @discardableResult
    public static func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) -> Bool {
        guard let top = topViewController else { return false }
        top.present(viewController, animated: animated, completion: completion)
        return true
    }
    
    /// Pop 返回上一页
    @discardableResult
    public static func pop(animated: Bool = true) -> UIViewController? {
        return currentNavigationController?.popViewController(animated: animated)
    }
    
    /// Pop 到指定页面
    @discardableResult
    public static func pop(to viewController: UIViewController, animated: Bool = true) -> [UIViewController]? {
        return currentNavigationController?.popToViewController(viewController, animated: animated)
    }
    
    /// Pop 到根视图
    @discardableResult
    public static func popToRoot(animated: Bool = true) -> [UIViewController]? {
        return currentNavigationController?.popToRootViewController(animated: animated)
    }
    
    /// Dismiss 关闭模态页面
    public static func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        topViewController?.dismiss(animated: animated, completion: completion)
    }
    
    /// 执行导航
    /// - Parameters:
    ///   - viewController: 目标页面
    ///   - type: 导航方式
    ///   - animated: 是否动画
    ///   - fallbackToPresent: Push 失败时是否降级为 Present
    ///   - navClass: 自定义导航控制器类型
    /// - Returns: 是否成功
    @discardableResult
    public static func navigate(
        to viewController: UIViewController,
        type: YFNavigateType,
        animated: Bool = true,
        fallbackToPresent: Bool = true,
        navClass: UINavigationController.Type = UINavigationController.self
    ) -> Bool {
        switch type {
        case .push:
            let success = push(viewController, animated: animated)
            // Push 失败时降级为 Present
            if !success && fallbackToPresent {
                return present(viewController, animated: animated)
            }
            return success
            
        case .present:
            return present(viewController, animated: animated)
            
        case .presentFullScreen:
            viewController.modalPresentationStyle = .fullScreen
            return present(viewController, animated: animated)
            
        case .presentWithNav:
            let nav = navClass.init(rootViewController: viewController)
            return present(nav, animated: animated)
        }
    }
    
    // MARK: - Private
    
    private static func findTopViewController(from viewController: UIViewController) -> UIViewController {
        // 优先处理 presented
        if let presented = viewController.presentedViewController {
            return findTopViewController(from: presented)
        }
        // NavigationController
        if let nav = viewController as? UINavigationController,
           let visible = nav.visibleViewController {
            return findTopViewController(from: visible)
        }
        // TabBarController
        if let tab = viewController as? UITabBarController,
           let selected = tab.selectedViewController {
            return findTopViewController(from: selected)
        }
        return viewController
    }
}
