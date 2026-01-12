# YFComponents

YF 组件库，单仓库多组件架构，包含以下模块：

## 组件列表

| 组件 | 说明 | 依赖 |
|------|------|------|
| **YFLogger** | 轻量级日志框架，支持分级日志、格式化输出、文件存储 | - |
| **YFExtensions** | iOS 常用扩展集合，支持子模块按需引入 | - |
| **YFStorage** | 轻量级数据存储封装（UserDefaults、Keychain、磁盘缓存） | - |
| **YFRouter** | 轻量级路由框架，支持页面注册、参数传递、拦截器 | YFLogger |
| **YFNetwork** | 基于 Moya 的易用网络请求封装 | Moya, YFLogger |
| **YFUIKit** | iOS 通用 UI 组件库 | SnapKit, YFExtensions/Color |
| **YFMedia** | 轻量级媒体选择和处理库 | YFUIKit, YFExtensions, YFLogger |
| **YFWebView** | WKWebView 封装，支持 JS 交互、进度条、Cookie 管理 | YFUIKit, YFLogger, SnapKit |

## 本地开发

```ruby
# Podfile
pod 'YFUIKit', :path => './YFComponents/YFUIKit'
pod 'YFNetwork', :path => './YFComponents/YFNetwork'
```

## 私有库使用

### 1. 添加 Specs 仓库

```bash
pod repo add YFSpecs https://github.com/syyjay/YFSpecs.git
```

### 2. Podfile 配置

```ruby
source 'https://github.com/syyjay/YFSpecs.git'
source 'https://cdn.cocoapods.org/'

platform :ios, '13.0'

target 'YourApp' do
  use_frameworks!

  pod 'YFNetwork', '~> 1.0.0'
  pod 'YFUIKit', '~> 1.0.0'
  # ... 其他组件
end
```

## 发布流程

```bash
# 1. 修改版本号后提交代码
git add .
git commit -m "Release xxx 1.0.0"
git push

# 2. 打标签（格式：组件名-版本号）
git tag YFLogger-1.0.0
git push origin YFLogger-1.0.0

# 3. 发布到 Specs 仓库
pod repo push YFSpecs YFLogger/YFLogger.podspec --allow-warnings
```

## 依赖关系

```
YFLogger (基础)
    ├── YFRouter
    ├── YFNetwork
    ├── YFWebView
    └── YFMedia

YFExtensions (基础)
    ├── YFUIKit
    └── YFMedia

YFUIKit
    ├── YFMedia
    └── YFWebView
```

## 按依赖顺序发布

1. YFLogger
2. YFExtensions
3. YFStorage
4. YFRouter
5. YFNetwork
6. YFUIKit
7. YFMedia
8. YFWebView

## License

MIT
