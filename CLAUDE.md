# CLAUDE.md

此文件为 Claude Code (claude.ai/code) 提供在此代码库中工作的指导。

## 项目概述

YFComponents 是一个**单仓库多组件**的 iOS 组件库架构，包含 8 个独立模块。每个组件都是独立的 CocoaPods Pod，可以单独使用或组合使用。

### 组件架构

| 组件 | 职责 | 依赖 |
|------|------|------|
| **YFLogger** | 轻量级日志框架（5级日志、格式化输出、文件存储） | - |
| **YFExtensions** | Foundation 扩展集合（String、Date、Array、Dictionary） | - |
| **YFStorage** | 数据存储封装（YFCache、YFDefaults、YFKeychain） | - |
| **YFRouter** | 路由框架（YFRoutable 协议、拦截器、URL Scheme） | YFLogger |
| **YFNetwork** | 基于 Moya 的网络请求封装 | Moya, YFLogger |
| **YFUIKit** | UI 组件库（主题系统、导航栏、Toast、空状态、基础控件） | SnapKit, YFExtensions/Color |
| **YFMedia** | 媒体选择和处理（图片/视频选择、裁剪、压缩） | YFUIKit, YFLogger |
| **YFWebView** | WKWebView 封装（JS 交互、进度条、Cookie 管理） | YFUIKit, YFLogger, SnapKit |

### 依赖关系图

```
基础层（无依赖）
├── YFLogger
└── YFExtensions

中间层
├── YFStorage
├── YFUIKit (依赖 SnapKit, YFExtensions/Color)
└── YFRouter (依赖 YFLogger)

应用层
├── YFNetwork (依赖 Moya, YFLogger)
├── YFMedia (依赖 YFUIKit, YFLogger)
└── YFWebView (依赖 YFUIKit, YFLogger, SnapKit)
```

**发布组件时必须按依赖顺序：** YFLogger → YFExtensions → YFStorage → YFRouter → YFNetwork → YFUIKit → YFMedia → YFWebView

## 常用命令

### 本地开发（在主项目中）

```bash
# 在主项目目录中执行
cd YFUniverseProject

# 安装/更新依赖（所有组件使用本地路径）
pod install

# 清理缓存后重新安装
pod cache clean --all
pod deintegrate
pod install

# 验证本地组件的 podspec
pod spec lint YFComponents/YFLogger/YFLogger.podspec --allow-warnings --sources=https://github.com/syyjay/YFSpecs.git
```

### 组件发布流程

```bash
# 1. 修改版本号（在组件的 podspec 文件中）
# 2. 提交代码
git add .
git commit -m "Release YFLogger 1.4.0"
git push

# 3. 打标签（格式：组件名-版本号）
git tag YFLogger-1.4.0
git push origin YFLogger-1.4.0

# 4. 发布到私有 Specs 仓库
pod repo push YFSpecs YFLogger/YFLogger.podspec --allow-warnings
```

### 使用发布脚本（批量发布）

```bash
# 使用 publish.sh 批量发布所有组件
# 注意：需要先修改脚本中的 VERSION 变量
./publish.sh
```

### 私有 Specs 仓库

- **仓库地址**: https://github.com/syyjay/YFSpecs.git
- **添加仓库**: `pod repo add YFSpecs https://github.com/syyjay/YFSpecs.git`
- **使用组件**:
  ```ruby
  source 'https://github.com/syyjay/YFSpecs.git'
  source 'https://cdn.cocoapods.org/'

  pod 'YFLogger', '~> 1.3.0'
  ```

## 代码架构

### 组件目录结构

每个组件遵循统一的结构：

```
YFComponentName/
├── YFComponentName.podspec    # Podspec 文件（放在根目录，统一本地/远程路径）
├── LICENSE                     # MIT 许可证
├── README.md                   # 组件文档（设计目标、架构、API）
└── YFComponentName/            # 源代码目录
    └── Classes/
        └── [源代码]
```

### podspec 路径配置

**重要设计决策：** podspec 文件放在组件根目录，但 `source_files` 路径包含组件名前缀。

```ruby
# 本地开发时（在主项目的 Podfile 中）
pod 'YFLogger', :path => './YFComponents'  # 指向 YFComponents 目录
# 实际路径为：YFComponents/YFLogger/Classes/**/*

# 远程发布时（自动修改 source_files）
s.source_files = 'YFLogger/Classes/**/*'  # 包含组件名前缀
```

这种设计使得本地路径和远程路径统一，避免了路径不一致的问题。

### 核心组件架构

#### YFLogger（日志系统）

**5 个日志级别：**
- `logV()` - VERBOSE（极详细调试）
- `logD()` - DEBUG（调试流程）
- `logI()` - INFO（重要业务事件）
- `logW()` - WARNING（需关注但不致命）
- `logE()` - ERROR（需处理的错误）

**环境配置：**
```swift
#if DEBUG
YFLogger.configure(with: .development)  // 控制台输出，全级别
#else
YFLogger.configure(with: .production)   // 仅文件存储，warning 以上
#endif
```

#### YFRouter（路由系统）

**核心概念：**
- **YFRoutable 协议** - 页面需实现此协议以支持路由
- **路由表** - 路径字符串 → 页面类型的映射
- **拦截器** - 登录检查、权限验证等统一处理
- **URL Scheme** - 支持 DeepLink

**页面注册方式：**
```swift
// 方式一：协议实现
class UserProfileViewController: UIViewController, YFRoutable {
    static var routePath: String { "/user/profile" }
    static func instance(with params: [String: Any]?) -> Self? { ... }
}

YFRouter.register([UserProfileViewController.self])

// 方式二：闭包注册（无法实现协议时）
YFRouter.register("/web") { params in
    let vc = WebViewController()
    vc.url = params?["url"] as? String
    return vc
}
```

#### YFUIKit（UI 组件库）

**目录结构：**
```
YFUIKit/Classes/
├── Core/           # 核心类（YFUIKit、YFBaseView、YFBaseViewController）
├── Theme/          # 主题系统（YFThemeManager、YFColorPalette、YFThemeType）
├── Navigation/     # 导航组件（YFNavigationBar、YFTabBar、YFNavigationController）
├── Controls/       # 基础控件（YFButton、YFLabel、YFTextField 等 11 个控件）
└── Feedback/       # 反馈组件（Toast、Alert、Loading）
```

**主题系统架构：**

双维度设计：
1. **主题 (Theme)** - 颜色风格（如默认蓝色、海洋蓝、暖橙色等）
2. **外观模式 (Appearance)** - 浅色/暗黑模式切换

**使用 `.themed()` 颜色是关键：**
```swift
// ✅ 主题切换时自动更新
view.backgroundColor = .themed(\.background)
label.textColor = .themed(\.textPrimary)

// ❌ 主题切换时不会更新
view.backgroundColor = YFUIKit.theme.colors.background
```

**自定义主题扩展：**
```swift
// 1. 扩展主题类型
extension YFThemeType {
    static let ocean = YFThemeType(rawValue: "ocean")
}

// 2. 定义配色
private static let oceanTheme = YFTheme(
    colors: YFColorPalette(
        primary: .dynamic(light: "#00A5A8", dark: "#00CED1"),
        // ...
    )
)

// 3. 注册到管理器
YFThemeManager.register([.ocean: oceanTheme])
```

**CGColor 不支持动态颜色：**

对于 `CALayer` 属性，需要在 `traitCollectionDidChange` 中手动更新：

```swift
override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
        layer.borderColor = UIColor.themed(\.border).resolvedColor(with: traitCollection).cgColor
    }
}
```

#### YFStorage（数据存储）

**三种存储方式选择：**

```
需要存储什么数据？
    │
    ├─ 敏感数据（Token、密码、密钥）
    │   └─ 使用 YFKeychain ✅
    │
    ├─ 用户配置、偏好设置
    │   └─ 使用 YFDefaults ✅
    │
    └─ 可重新获取的缓存（图片、API响应）
        └─ 使用 YFCache ✅
```

#### YFExtensions（扩展集合）

**Foundation 子模块：**
- `String+YF.swift` - 字符串扩展（截取、验证、正则等）
- `Date+YF.swift` - 日期扩展（格式化、计算、转换等）
- `Array+YF.swift` - 数组扩展（安全访问、转换等）
- `Dictionary+YF.swift` - 字典扩展（安全访问、合并等）

**使用子模块：**
```ruby
pod 'YFExtensions/Foundation', :path => './YFComponents'
```

## 组件开发指南

### 添加新组件

1. **创建组件目录结构：**
   ```
   YFComponents/
   └── YFNewComponent/
       ├── YFNewComponent.podspec
       ├── LICENSE
       ├── README.md
       └── YFNewComponent/
           └── Classes/
               └── [源代码]
   ```

2. **编写 podspec（注意路径配置）：**
   ```ruby
   Pod::Spec.new do |s|
     s.name             = 'YFNewComponent'
     s.version          = '1.0.0'
     s.source_files = 'YFNewComponent/Classes/**/*'  # 包含组件名前缀
     # ...
   end
   ```

3. **更新主项目的 Podfile：**
   ```ruby
   pod 'YFNewComponent', :path => './YFComponents'
   ```

4. **更新 YFComponents/README.md** - 添加组件到列表和依赖关系图

5. **运行 `pod install`** - 在主项目目录中执行

### 组件文档规范

每个组件的 README.md 应包含：
- **设计目标** - 解决什么问题
- **核心概念** - 关键术语和概念
- **架构设计** - 架构图和模块关系
- **快速开始** - 最简示例
- **详细使用** - 完整 API 文档
- **最佳实践** - 推荐用法

## 代码规范

### Swift 编码

- **Swift 版本**: 5.0
- **iOS 部署目标**: 13.0（所有组件）
- **使用 `.xcworkspace`** 而非 `.xcodeproj`（在主项目中）

### 导入顺序

```swift
// 1. 系统框架
import UIKit

// 2. 第三方库
import SnapKit
import Moya

// 3. YF 组件（按字母顺序）
import YFLogger
import YFRouter
import YFUIKit

// 4. 项目模块
import MyAppModule
```

### 命名规范

- **路由路径**: 使用 `/` 开头，层级清晰（如 `/user/profile`）
- **常量**: 使用结构体组织（如 `RoutePaths.home`、`RouteParams.userId`）
- **主题扩展**: 在应用的 `AppTheme.swift` 中扩展 `YFThemeType`
- **组件前缀**: 所有公共类以 `YF` 开头

## 常见问题

### 组件修改后不生效

```bash
# 清理构建缓存
# Xcode: Product → Clean Build Folder (Shift+Cmd+K)

# 或命令行（在主项目目录）
rm -rf ~/Library/Developer/Xcode/DerivedData/YFUniverseProject-*
pod install
```

### 主题切换后颜色未更新

确保使用 `.themed()` 而非直接访问 `theme.colors`：

```swift
// ✅ 正确
view.backgroundColor = .themed(\.background)

// ❌ 错误
view.backgroundColor = YFUIKit.theme.colors.background
```

### podspec 路径错误

**错误示例：**
```
- ERROR | [iOS] unknown: Encountered an unknown error (The source_files for ... does not exist)
```

**解决方案：**
- 确保 `source_files` 路径包含组件名前缀：`'YFComponentName/Classes/**/*'`
- 本地开发时 Podfile 中使用 `:path => './YFComponents'`

## 第三方依赖

| 库 | 版本 | 用途 | 被组件依赖 |
|---|------|------|-----------|
| **SnapKit** | 5.7.1 | DSL 式 Auto Layout | YFUIKit, YFWebView |
| **Moya** | 15.0.0 | 网络抽象层 | YFNetwork |
| **Alamofire** | 5.11.0 | HTTP 网络（Moya 的底层依赖） | Moya |

## 项目元数据

- **平台**: iOS 13.0+
- **语言**: Swift 5.0
- **包管理**: CocoaPods
- **私有 Specs**: https://github.com/syyjay/YFSpecs.git
- **组件仓库**: https://github.com/syyjay/YFComponents.git
- **许可证**: MIT
- **组件数量**: 8 个独立模块
- **Swift 文件总数**: ~75 个
