//
//  UIColor+Theme.swift
//  YFUIKit
//
//  主题感知的动态颜色扩展
//
//  ## 为什么需要这个？
//
//  普通的动态颜色 `UIColor.dynamic(light:dark:)` 在创建时就固定了 light/dark 值：
//  ```swift
//  let color = UIColor.dynamic(light: "#007AFF", dark: "#0A84FF")
//  // 这个 UIColor 对象内部的 light/dark 值是固定的
//  ```
//
//  当你把这个颜色赋值给 view.backgroundColor 后，切换主题时：
//  - 触发 traitCollection 变化 → 系统重新解析颜色
//  - 但解析时用的还是创建时的固定值 → 颜色不变！
//
//  ## 解决方案
//
//  使用 `.themed(\.xxx)` 创建的颜色，每次系统解析时都会从当前主题获取：
//  ```swift
//  view.backgroundColor = .themed(\.primary)
//  // 切换主题后，系统解析颜色时会调用闭包
//  // 闭包内从 YFThemeManager.shared.theme 获取当前主题的颜色
//  ```
//

import UIKit

public extension UIColor {
    
    // MARK: - 主题感知颜色
    
    /// 创建主题感知的动态颜色
    ///
    /// 与普通动态颜色的区别：
    /// - `UIColor.dynamic(light:dark:)`: 创建时固定值，主题切换后不变
    /// - `UIColor.themed(\.xxx)`: 每次渲染时从当前主题获取，主题切换后自动更新
    ///
    /// - Parameter keyPath: 颜色在 YFColorPalette 中的 KeyPath
    /// - Returns: 主题感知的动态颜色
    ///
    /// 使用示例:
    /// ```swift
    /// view.backgroundColor = .themed(\.background)
    /// label.textColor = .themed(\.textPrimary)
    /// button.backgroundColor = .themed(\.primary)
    /// ```
    static func themed(_ keyPath: KeyPath<YFColorPalette, UIColor>) -> UIColor {
        return UIColor { traitCollection in
            // 每次系统需要解析颜色时，都从当前主题获取
            let currentTheme = YFThemeManager.shared.theme
            let color = currentTheme.colors[keyPath: keyPath]
            // 根据当前 traitCollection 解析动态颜色
            return color.resolvedColor(with: traitCollection)
        }
    }
    
    /// 创建主题感知的动态颜色（带透明度）
    static func themed(_ keyPath: KeyPath<YFColorPalette, UIColor>, alpha: CGFloat) -> UIColor {
        return UIColor { traitCollection in
            let currentTheme = YFThemeManager.shared.theme
            let color = currentTheme.colors[keyPath: keyPath]
            return color.resolvedColor(with: traitCollection).withAlphaComponent(alpha)
        }
    }
}
