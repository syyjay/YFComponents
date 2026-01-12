# YFUIKit

YFUIKit 是一个 iOS UI 组件库，提供主题系统、自定义导航栏、基础控件、弹窗、加载指示器等常用 UI 组件。

## 功能特性

- 🎨 **主题系统** - 多主题支持，切换时自动刷新所有 UI
- 📱 **自定义导航栏** - 替代系统导航栏，支持透明、渐变等效果
- 🧩 **基础控件** - 封装常用控件，支持链式调用和主题
- 💬 **弹窗系统** - Toast、Alert、ActionSheet 等
- ⏳ **加载指示器** - Loading、Progress 等
- 📭 **空状态视图** - 无数据、无网络等空状态展示

## 安装

```ruby
pod 'YFUIKit', :path => './Components/YFUIKit'
```

---

## 主题系统

### 核心概念

YFUIKit 的主题系统将「**主题**」和「**外观模式**」分离：

- **主题 (Theme)** - 一套颜色风格（如默认蓝色、海洋蓝、暖橙色等）
- **外观模式 (Appearance)** - 浅色/暗黑模式切换

每个主题都包含浅色和暗黑两个版本的颜色，使用动态颜色自动适配。

### 架构设计

```
┌─────────────────────────────────────────────────────────────┐
│                      私有库 (YFUIKit)                        │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │ YFThemeManager  │  │ YFColorPalette  │                   │
│  │ (主题管理器)     │  │ (默认配色)       │                   │
│  └─────────────────┘  └─────────────────┘                   │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │ YFThemeType     │  │ YFTheme         │                   │
│  │ (可扩展标识符)   │  │ (默认主题)       │                   │
│  └─────────────────┘  └─────────────────┘                   │
└─────────────────────────────────────────────────────────────┘
                            ↓ 扩展
┌─────────────────────────────────────────────────────────────┐
│                      业务层 (App)                            │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ AppTheme.swift                                       │    │
│  │ - 扩展 YFThemeType（添加 .ocean, .warm 等）          │    │
│  │ - 定义自定义 YFColorPalette                          │    │
│  │ - 注册主题到 YFThemeManager                          │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## 使用方法

### 1. 注册自定义主题（App 启动时）

```swift
// AppTheme.swift
extension YFThemeType {
    static let ocean = YFThemeType(rawValue: "ocean")
    static let warm = YFThemeType(rawValue: "warm")
}

struct AppTheme {
    static func register() {
        YFThemeManager.register([
            .ocean: YFTheme(colors: oceanColors),
            .warm: YFTheme(colors: warmColors)
        ])
    }
    
    private static let oceanColors = YFColorPalette(
        primary: .dynamic(light: "#00A5A8", dark: "#00CED1"),
        // ... 其他颜色
    )
}

// SceneDelegate.swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, ...) {
    AppTheme.register()  // 注册主题
    // ...
}
```

### 2. 切换主题

```swift
// 切换到海洋蓝主题
YFThemeManager.setTheme(.ocean)

// 切换回默认主题
YFThemeManager.setTheme(.default)
```

### 3. 切换外观模式

```swift
// 跟随系统
YFThemeManager.setAppearanceMode(.system)

// 强制浅色
YFThemeManager.setAppearanceMode(.light)

// 强制暗黑
YFThemeManager.setAppearanceMode(.dark)
```

### 4. 使用主题颜色（推荐方式）

```swift
// ✅ 推荐：使用 .themed() - 主题切换时自动更新
view.backgroundColor = .themed(\.background)
label.textColor = .themed(\.textPrimary)
button.backgroundColor = .themed(\.primary)

// ❌ 不推荐：直接使用 theme.colors - 主题切换时不会更新
view.backgroundColor = theme.colors.background
```

### 5. 获取当前状态

```swift
// 当前主题类型
let themeType = YFThemeManager.shared.currentThemeType

// 当前外观模式
let appearanceMode = YFThemeManager.shared.currentAppearanceMode

// 当前主题配置
let theme = YFThemeManager.shared.theme

// 便捷访问
let theme = YFUIKit.theme

// 是否为暗黑模式
let isDark = YFThemeManager.isDarkMode
```

---

## 主题自动刷新机制

### 为什么使用 `.themed()`？

普通颜色在赋值时就固定了：

```swift
// 创建时获取的是当前主题的颜色
view.backgroundColor = theme.colors.primary  // 假设是蓝色

// 切换主题后
YFThemeManager.setTheme(.ocean)  // 海洋主题是青色

// ❌ 问题：view.backgroundColor 还是蓝色！
```

使用 `.themed()` 解决这个问题：

```swift
view.backgroundColor = .themed(\.primary)

// 切换主题后
YFThemeManager.setTheme(.ocean)

// ✅ view.backgroundColor 自动变成青色
```

### 技术原理

`.themed()` 返回一个**动态代理颜色**：

```swift
extension UIColor {
    static func themed(_ keyPath: KeyPath<YFColorPalette, UIColor>) -> UIColor {
        return UIColor { traitCollection in
            // 每次系统渲染颜色时调用
            let currentTheme = YFThemeManager.shared.theme  // 获取「此刻」的主题
            return currentTheme.colors[keyPath: keyPath].resolvedColor(with: traitCollection)
        }
    }
}
```

### 主题切换时如何刷新？

切换主题时，通过**强制触发 `traitCollection` 变化**让系统重新解析所有动态颜色：

```swift
private static func forceRefreshAllWindows() {
    // 禁用动画，避免闪烁
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    
    // 临时切换到相反的外观模式
    windows.forEach { $0.overrideUserInterfaceStyle = tempStyle }
    
    // 强制布局，触发 traitCollectionDidChange
    windows.forEach { $0.layoutIfNeeded() }
    
    // 立即切回原来的外观模式
    windows.forEach { $0.overrideUserInterfaceStyle = currentStyle }
    
    CATransaction.commit()
}
```

**为什么使用 `CATransaction`？**

1. `setDisableActions(true)` 禁用所有 Core Animation 隐式动画
2. 确保「切换→还原」在**同一帧**内完成，避免闪烁
3. 防御性编程，即使未来 iOS 版本改变行为也能正常工作

---

## 颜色配置 (YFColorPalette)

### 颜色分类

| 分类 | 属性 | 说明 |
|------|------|------|
| **主色** | `primary` | 主色调 |
| | `primaryLight` | 主色浅色版 |
| | `primaryDark` | 主色深色版 |
| **辅助色** | `secondary` | 辅助色 |
| | `accent` | 强调色 |
| **功能色** | `success` | 成功状态 |
| | `warning` | 警告状态 |
| | `error` | 错误状态 |
| | `info` | 信息状态 |
| **文字色** | `textPrimary` | 主要文字 |
| | `textSecondary` | 次要文字 |
| | `textTertiary` | 三级文字 |
| | `textDisabled` | 禁用文字 |
| **背景色** | `background` | 页面背景 |
| | `backgroundSecondary` | 次要背景 |
| | `surface` | 表面色（卡片、导航栏） |
| | `surfaceSecondary` | 次要表面色 |
| **边框色** | `border` | 边框 |
| | `divider` | 分割线 |

### 创建动态颜色

```swift
// 使用 Hex 字符串
let color = UIColor.dynamic(light: "#007AFF", dark: "#0A84FF")
```

---

## API 参考

### YFThemeManager

| 方法/属性 | 说明 |
|----------|------|
| `shared` | 单例实例 |
| `theme` | 当前主题配置 |
| `currentThemeType` | 当前主题类型 |
| `currentAppearanceMode` | 当前外观模式 |
| `allThemeTypes` | 所有已注册的主题类型 |
| `register(_:for:)` | 注册单个主题 |
| `register(_:)` | 批量注册主题 |
| `setTheme(_:)` | 切换主题（自动刷新所有 UI） |
| `setAppearanceMode(_:animated:)` | 切换外观模式 |
| `isDarkMode` | 是否为暗黑模式 |
| `themeDidChangeNotification` | 主题变更通知 |

### UIColor.themed

| 方法 | 说明 |
|------|------|
| `.themed(\.xxx)` | 创建主题感知的动态颜色 |

### YFThemeType

`YFThemeType` 是一个可扩展的结构体：

```swift
// 私有库内置
static let `default` = YFThemeType(rawValue: "default")

// 业务层扩展
extension YFThemeType {
    static let ocean = YFThemeType(rawValue: "ocean")
    static let warm = YFThemeType(rawValue: "warm")
}
```

### YFAppearanceMode

| 枚举值 | 说明 |
|--------|------|
| `.system` | 跟随系统 |
| `.light` | 浅色模式 |
| `.dark` | 暗黑模式 |

---

## 最佳实践

### 1. 始终使用 `.themed()` 颜色

```swift
// ✅ 推荐
view.backgroundColor = .themed(\.background)
label.textColor = .themed(\.textPrimary)

// ❌ 不推荐
view.backgroundColor = .white
label.textColor = .black
```

### 2. CGColor 需要手动更新

由于 `CALayer` 的属性不支持动态颜色，需要在 `traitCollectionDidChange` 中更新：

```swift
override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
        layer.borderColor = UIColor.themed(\.border).resolvedColor(with: traitCollection).cgColor
        layer.shadowColor = UIColor.themed(\.primary).resolvedColor(with: traitCollection).cgColor
    }
}
```

### 3. 使用封装控件

优先使用 `YFLabel`、`YFButton` 等封装控件，它们默认支持主题切换。

### 4. 主题定义放在业务层

私有库只提供默认主题和主题机制，自定义主题（如品牌色）应该在各项目的 `AppTheme.swift` 中定义。

---

## License

MIT License
