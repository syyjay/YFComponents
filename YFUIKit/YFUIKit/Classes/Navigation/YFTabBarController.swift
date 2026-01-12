//
//  YFTabBarController.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// TabBar 项配置
public struct YFTabBarItem {
    public let title: String
    public let image: UIImage?
    public let selectedImage: UIImage?
    public let viewController: UIViewController
    
    public init(
        title: String,
        image: UIImage?,
        selectedImage: UIImage? = nil,
        viewController: UIViewController
    ) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage ?? image
        self.viewController = viewController
    }
    
    /// 使用 SF Symbols 创建
    public init(
        title: String,
        systemName: String,
        selectedSystemName: String? = nil,
        viewController: UIViewController
    ) {
        self.title = title
        self.image = UIImage(systemName: systemName)
        self.selectedImage = UIImage(systemName: selectedSystemName ?? "\(systemName).fill") ?? self.image
        self.viewController = viewController
    }
}

/// 自定义 TabBar 控制器
open class YFTabBarController: UITabBarController {
    
    // MARK: - Properties
    
    /// 当前主题
    public var theme: YFTheme {
        return YFUIKit.theme
    }
    
    /// 自定义 TabBar
    public let customTabBar = YFTabBar()
    
    /// TabBar 项配置
    private var tabItems: [YFTabBarItem] = []
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomTabBar()
    }
    
    // MARK: - Setup
    
    private func setupCustomTabBar() {
        // 替换系统 TabBar
        setValue(customTabBar, forKey: "tabBar")
    }
    
    // MARK: - Public Methods
    
    /// 配置 TabBar 项
    /// - Parameters:
    ///   - items: TabBar 项配置数组
    ///   - wrapInNavigation: 是否自动包装在导航控制器中
    public func configure(items: [YFTabBarItem], wrapInNavigation: Bool = true) {
        self.tabItems = items
        
        var viewControllers: [UIViewController] = []
        
        for item in items {
            let vc: UIViewController
            
            if wrapInNavigation && !(item.viewController is UINavigationController) {
                let nav = YFNavigationController(rootViewController: item.viewController)
                vc = nav
            } else {
                vc = item.viewController
            }
            
            vc.tabBarItem = UITabBarItem(
                title: item.title,
                image: item.image?.withRenderingMode(.alwaysTemplate),
                selectedImage: item.selectedImage?.withRenderingMode(.alwaysTemplate)
            )
            
            viewControllers.append(vc)
        }
        
        self.viewControllers = viewControllers
    }
    
    /// 添加中间凸起按钮
    public func addCenterButton(
        image: UIImage?,
        size: CGFloat = 56,
        backgroundColor: UIColor? = nil,
        action: @escaping () -> Void
    ) {
        customTabBar.addCenterButton(
            image: image,
            size: size,
            backgroundColor: backgroundColor
        )
        customTabBar.onCenterButtonTap = action
    }
    
    /// 选中指定索引的 Tab
    public func selectTab(at index: Int, animated: Bool = false) {
        guard index >= 0, index < (viewControllers?.count ?? 0) else { return }
        selectedIndex = index
    }
    
    /// 设置角标
    public func setBadge(_ value: String?, at index: Int) {
        guard index >= 0, index < (viewControllers?.count ?? 0) else { return }
        viewControllers?[index].tabBarItem.badgeValue = value
    }
    
    /// 设置角标（数字）
    public func setBadgeCount(_ count: Int, at index: Int) {
        if count <= 0 {
            setBadge(nil, at: index)
        } else if count > 99 {
            setBadge("99+", at: index)
        } else {
            setBadge("\(count)", at: index)
        }
    }
    
    /// 显示小红点
    public func showDot(at index: Int) {
        setBadge("", at: index)
    }
    
    /// 隐藏角标/小红点
    public func hideBadge(at index: Int) {
        setBadge(nil, at: index)
    }
}
