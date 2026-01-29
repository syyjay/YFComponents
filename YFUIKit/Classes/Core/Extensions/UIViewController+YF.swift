//
//  UIViewController+YF.swift
//  YFUIKit
//
//  UIViewController 扩展
//

import UIKit

public extension UIViewController {

    // MARK: - 导航

    /// 是否是根控制器
    var isRootViewController: Bool {
        navigationController?.viewControllers.first == self
    }

    /// 是否是模态呈现
    var isModal: Bool {
        if presentingViewController != nil {
            return true
        }
        if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        }
        if tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        return false
    }

    /// 获取顶层 ViewController
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }
        if let nav = self as? UINavigationController, let visible = nav.visibleViewController {
            return visible.topMostViewController
        }
        if let tab = self as? UITabBarController, let selected = tab.selectedViewController {
            return selected.topMostViewController
        }
        return self
    }

    // MARK: - 子控制器

    /// 添加子控制器
    func add(child: UIViewController, to containerView: UIView? = nil) {
        addChild(child)
        let container = containerView ?? view
        container?.addSubview(child.view)
        child.view.frame = container?.bounds ?? .zero
        child.didMove(toParent: self)
    }

    /// 移除子控制器
    func removeFromParentViewController() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

    // MARK: - 键盘

    /// 点击空白处收起键盘
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAction))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboardAction() {
        view.endEditing(true)
    }

    // MARK: - StoryBoard

    /// 从 Storyboard 实例化
    static func instantiate(fromStoryboard name: String, identifier: String? = nil) -> Self? {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let id = identifier ?? String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: id) as? Self
    }
}
