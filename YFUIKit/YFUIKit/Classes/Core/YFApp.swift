//
//  YFApp.swift
//  YFUIKit
//
//  App 级别工具方法
//

import UIKit

/// App 级别工具类
public struct YFApp {
    
    private init() {}
    
    // MARK: - Window
    
    /// 获取当前 keyWindow
    public static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    /// 获取当前 windowScene
    public static var windowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes.first as? UIWindowScene
    }
    
    // MARK: - ViewController
    
    /// 获取最顶层的 ViewController
    public static var topViewController: UIViewController? {
        guard var vc = keyWindow?.rootViewController else { return nil }
        while let presented = vc.presentedViewController {
            vc = presented
        }
        if let nav = vc as? UINavigationController {
            return nav.visibleViewController ?? nav
        }
        if let tab = vc as? UITabBarController {
            return tab.selectedViewController ?? tab
        }
        return vc
    }
    
    /// 获取根 ViewController
    public static var rootViewController: UIViewController? {
        keyWindow?.rootViewController
    }
    
    // MARK: - Screen & SafeArea
    
    /// 获取安全区域
    public static var safeAreaInsets: UIEdgeInsets {
        keyWindow?.safeAreaInsets ?? .zero
    }
    
    /// 获取状态栏高度
    public static var statusBarHeight: CGFloat {
        windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
    
    /// 获取屏幕尺寸
    public static var screenSize: CGSize {
        keyWindow?.bounds.size ?? UIScreen.main.bounds.size
    }
    
    /// 屏幕宽度
    public static var screenWidth: CGFloat {
        screenSize.width
    }
    
    /// 屏幕高度
    public static var screenHeight: CGFloat {
        screenSize.height
    }
    
    /// 是否是刘海屏
    public static var hasNotch: Bool {
        safeAreaInsets.bottom > 0
    }
}

