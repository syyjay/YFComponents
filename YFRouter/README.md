# YFRouter

轻量级 iOS 路由框架，支持页面注册、参数传递、拦截器、URL Scheme 解析。

---

## 目录

- [设计目标](#设计目标)
- [核心概念](#核心概念)
- [架构设计](#架构设计)
- [快速开始](#快速开始)
- [详细使用](#详细使用)
- [拦截器](#拦截器)
- [API 参考](#api-参考)
- [最佳实践](#最佳实践)

---

## 设计目标

### 解决的问题

**传统页面跳转的痛点：**

```swift
// ❌ 传统方式：强耦合
import UserModule  // 需要导入目标模块

let vc = UserProfileViewController()
vc.userId = "123"
navigationController?.pushViewController(vc, animated: true)
```

**存在的问题：**
1. **强耦合**：调用方必须 `import` 目标模块
2. **难以维护**：修改页面初始化方式需要改动所有调用处
3. **无法拦截**：登录检查、权限验证等逻辑散落在各处
4. **不支持 DeepLink**：外部链接无法统一处理

**路由方式：解耦**

```swift
// ✅ 路由方式：解耦
YFRouter.push("/user/profile", params: ["userId": "123"])
```

**优势：**
1. **解耦**：只需知道路径字符串，不需要导入目标模块
2. **统一入口**：所有页面跳转走同一通道
3. **可拦截**：登录、权限等逻辑统一处理
4. **支持 DeepLink**：URL 自动解析为路由

---

## 核心概念

### 1. 路由表

路由器维护一个「路径 → 页面类型」的映射表：

```
┌──────────────────┬────────────────────────────┐
│      路径         │         页面类型            │
├──────────────────┼────────────────────────────┤
│  /home           │  HomeViewController        │
│  /user/profile   │  UserProfileViewController │
│  /order/detail   │  OrderDetailViewController │
│  /settings       │  SettingsViewController    │
└──────────────────┴────────────────────────────┘
```

**注册方式：**
```swift
YFRouter.register(HomeViewController.self)
YFRouter.register(UserProfileViewController.self)
```

### 2. 可路由协议 (YFRoutable)

页面需要实现 `YFRoutable` 协议，告诉路由器：
- **我的路径是什么**：`routePath`
- **如何创建我**：`instance(with:)`

```swift
class UserProfileViewController: UIViewController, YFRoutable {
    
    // 1️⃣ 定义路径
    static var routePath: String { "/user/profile" }
    
    var userId: String?
    
    // 2️⃣ 定义如何从参数创建实例
    static func instance(with params: [String: Any]?) -> Self? {
        let vc = Self.init()
        vc.userId = params?["userId"] as? String
        return vc
    }
}
```

### 3. 参数传递

**发送参数：**
```swift
YFRouter.push("/user/profile", params: ["userId": "123", "from": "home"])
```

**接收参数（方式一）：在 instance 方法中解析**
```swift
static func instance(with params: [String: Any]?) -> Self? {
    let vc = Self.init()
    vc.userId = params?["userId"] as? String
    return vc
}
```

**接收参数（方式二）：使用便捷方法**
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    // 获取字符串参数
    let userId = yf_stringParam("userId")
    
    // 获取整数参数
    let page = yf_intParam("page")
    
    // 获取任意类型参数
    let data: MyModel? = yf_param("data")
}
```

### 4. 拦截器

拦截器在路由执行前检查，可用于：
- 登录验证
- 权限检查
- 埋点统计
- A/B 测试

**执行流程：**
```
跳转请求 → 拦截器1 → 拦截器2 → ... → 创建页面 → 执行导航
              │          │
              ↓          ↓
            拦截        拦截
              │          │
              ↓          ↓
          跳转登录    提示无权限
```

---

## 架构设计

```
┌─────────────────────────────────────────────────────────────┐
│                         YFRouter                             │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                      路由表 (routes)                     │ │
│  │                                                         │ │
│  │   路径 (String)  ──────────→  页面类型 (YFRoutable.Type) │ │
│  │                                                         │ │
│  └────────────────────────────────────────────────────────┘ │
│                              ↑                               │
│                           register                           │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│   open(path, params, type)                                   │
│            │                                                 │
│            ▼                                                 │
│   ┌─────────────────┐                                        │
│   │   拦截器链       │  ← YFRouterInterceptor                 │
│   │  (Interceptors) │     • 登录拦截器                        │
│   └────────┬────────┘     • 权限拦截器                        │
│            │ 通过                                             │
│            ▼                                                 │
│   ┌─────────────────┐                                        │
│   │   查找路由       │  ← 从 routes 字典查找                   │
│   └────────┬────────┘                                        │
│            │ 找到                                             │
│            ▼                                                 │
│   ┌─────────────────┐                                        │
│   │   创建实例       │  ← 调用 Routable.instance(with:)       │
│   └────────┬────────┘                                        │
│            │                                                 │
│            ▼                                                 │
│   ┌─────────────────┐                                        │
│   │   YFNavigator   │  ← 执行实际导航操作                      │
│   │  push/present   │                                        │
│   └─────────────────┘                                        │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 目录结构

```
YFRouter/
├── YFRouter.podspec
├── LICENSE
├── README.md
└── YFRouter/
    └── Classes/
        ├── Core/
        │   ├── YFRouter.swift         # 核心路由器
        │   ├── YFRouterConfig.swift   # 路由配置
        │   └── YFRoutable.swift       # 可路由协议
        ├── Navigator/
        │   └── YFNavigator.swift      # 导航器
        └── Interceptor/
            └── YFRouterInterceptor.swift  # 拦截器
```

### 各模块职责

| 模块 | 职责 |
|------|------|
| **YFRouter** | 核心路由器，管理路由表，执行路由逻辑 |
| **YFRoutable** | 可路由协议，页面需实现此协议 |
| **YFRouterConfig** | 路由配置，包含 scheme、拦截器等 |
| **YFNavigator** | 导航器，封装 push/present/pop 等操作 |
| **YFRouterInterceptor** | 拦截器协议及内置拦截器 |

---

## 快速开始

### 1. 安装

在 `Podfile` 中添加：

```ruby
pod 'YFRouter', :path => './Components/YFRouter'
```

执行：
```bash
pod install
```

### 2. 配置路由器

在 `AppDelegate` 或 `SceneDelegate` 中初始化：

```swift
import YFRouter

func setupRouter() {
    // 配置
    YFRouter.configure { config in
        config.scheme = "myapp"
        config.onNotFound { path, params in
            print("页面未找到: \(path)")
        }
    }
    
    // 注册页面
    YFRouter.register([
        HomeViewController.self,
        UserProfileViewController.self,
        SettingsViewController.self
    ])
}
```

### 3. 页面实现协议

```swift
class UserProfileViewController: UIViewController, YFRoutable {
    
    static var routePath: String { "/user/profile" }
    
    var userId: String?
    
    static func instance(with params: [String: Any]?) -> Self? {
        let vc = Self.init()
        vc.userId = params?["userId"] as? String
        return vc
    }
}
```

### 4. 使用路由跳转

```swift
// Push
YFRouter.push("/user/profile", params: ["userId": "123"])

// Present
YFRouter.present("/login")

// Pop
YFRouter.pop()

// Dismiss
YFRouter.dismiss()
```

---

## 详细使用

### 导航方式

```swift
// 1. Push（默认）
YFRouter.open("/user/profile", type: .push)
YFRouter.push("/user/profile")

// 2. Present
YFRouter.open("/login", type: .present)
YFRouter.present("/login")

// 3. Present 全屏
YFRouter.open("/welcome", type: .presentFullScreen)
YFRouter.presentFullScreen("/welcome")

// 4. Present 带导航栏
YFRouter.open("/edit", type: .presentWithNav)
```

### URL Scheme 支持

```swift
// 配置 scheme
YFRouter.configure { config in
    config.scheme = "myapp"
}

// 通过 URL 跳转
YFRouter.open(url: "myapp://user/profile?userId=123")

// 在 SceneDelegate 中处理外部链接
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    if let url = URLContexts.first?.url {
        YFRouter.handleURL(url)
    }
}
```

### 获取页面实例（不跳转）

```swift
// 获取页面实例，用于自定义处理
if let vc = YFRouter.viewController(for: "/user/profile", params: ["userId": "123"]) {
    // 自定义处理
    vc.modalPresentationStyle = .pageSheet
    present(vc, animated: true)
}
```

### 动态注册

对于不方便实现 `YFRoutable` 的页面：

```swift
// 使用闭包注册
YFRouter.register("/web") { params in
    let vc = WebViewController()
    vc.url = params?["url"] as? String
    return vc
}

// 使用
YFRouter.push("/web", params: ["url": "https://example.com"])
```

---

## 拦截器

### 登录拦截器

```swift
// 创建登录拦截器
let loginInterceptor = YFLoginInterceptor()
    .require("/user/profile", "/order/list", "/settings")  // 需要登录的页面
    .checkLogin { UserManager.shared.isLoggedIn }          // 登录检查
    .whenNeedLogin { path, params in                       // 未登录处理
        YFRouter.present("/login")
    }

// 添加到配置
YFRouter.configure { config in
    config.addInterceptor(loginInterceptor)
}
```

### 自定义拦截器

```swift
// 埋点拦截器
class TrackingInterceptor: YFRouterInterceptor {
    
    var name: String { "TrackingInterceptor" }
    
    func shouldOpen(path: String, params: [String: Any]?) -> Bool {
        // 记录页面访问
        Analytics.track("page_view", properties: [
            "path": path,
            "params": params ?? [:]
        ])
        return true  // 始终放行
    }
}

// A/B 测试拦截器
class ABTestInterceptor: YFRouterInterceptor {
    
    var name: String { "ABTestInterceptor" }
    
    func shouldOpen(path: String, params: [String: Any]?) -> Bool {
        if path == "/home" && ABTest.isInGroup("new_home") {
            YFRouter.push("/home_v2", params: params)
            return false  // 拦截原路由
        }
        return true
    }
}
```

### 拦截器执行顺序

拦截器按添加顺序依次执行，任一拦截器返回 `false` 则终止：

```swift
YFRouter.configure { config in
    config.addInterceptor(loggingInterceptor)   // 1. 日志（始终通过）
    config.addInterceptor(loginInterceptor)     // 2. 登录检查
    config.addInterceptor(permissionInterceptor) // 3. 权限检查
}
```

---

## API 参考

### YFRouter

| 方法 | 说明 |
|------|------|
| `configure(_:)` | 配置路由器 |
| `register(_:)` | 注册页面或处理器 |
| `isRegistered(_:)` | 检查路径是否已注册 |
| `open(_:params:type:animated:)` | 打开页面 |
| `open(url:type:animated:)` | 通过 URL 打开页面 |
| `handleURL(_:)` | 处理外部 URL |
| `viewController(for:params:)` | 获取页面实例 |
| `push(_:params:animated:)` | Push 页面 |
| `present(_:params:animated:)` | Present 页面 |
| `pop(animated:)` | 返回上一页 |
| `popToRoot(animated:)` | 返回根视图 |
| `dismiss(animated:)` | 关闭模态页面 |

### YFRoutable

| 属性/方法 | 说明 |
|-----------|------|
| `routePath` | 路由路径（静态属性） |
| `instance(with:)` | 通过参数创建实例（静态方法） |

### UIViewController 扩展

| 属性/方法 | 说明 |
|-----------|------|
| `yf_routeParams` | 路由传递的参数 |
| `yf_param(_:)` | 获取指定类型参数 |
| `yf_stringParam(_:)` | 获取字符串参数 |
| `yf_intParam(_:)` | 获取整数参数 |

### YFNavigator

| 方法 | 说明 |
|------|------|
| `keyWindow` | 获取 keyWindow |
| `topViewController` | 获取顶层 VC |
| `currentNavigationController` | 获取当前导航控制器 |
| `push(_:animated:)` | Push 页面 |
| `present(_:animated:completion:)` | Present 页面 |
| `pop(animated:)` | 返回 |
| `popToRoot(animated:)` | 返回根视图 |
| `dismiss(animated:completion:)` | 关闭模态 |

---

## 最佳实践

### 1. 路径命名规范

```swift
// ✅ 推荐：使用 / 开头，层级清晰
"/home"
"/user/profile"
"/order/detail"
"/settings/notification"

// ❌ 不推荐
"home"
"user_profile"
"OrderDetail"
```

### 2. 集中管理路径

创建路径常量文件，避免硬编码：

```swift
struct RoutePaths {
    static let home = "/home"
    static let userProfile = "/user/profile"
    static let orderDetail = "/order/detail"
    static let settings = "/settings"
}

// 使用
YFRouter.push(RoutePaths.userProfile, params: ["userId": "123"])
```

### 3. 模块化注册

每个模块负责注册自己的路由：

```swift
// UserModule
public class UserModule {
    public static func registerRoutes() {
        YFRouter.register([
            UserProfileViewController.self,
            UserSettingsViewController.self
        ])
    }
}

// OrderModule
public class OrderModule {
    public static func registerRoutes() {
        YFRouter.register([
            OrderListViewController.self,
            OrderDetailViewController.self
        ])
    }
}

// AppDelegate
func setupRouter() {
    UserModule.registerRoutes()
    OrderModule.registerRoutes()
}
```

### 4. 参数类型安全

定义参数 Key 常量：

```swift
struct RouteParams {
    static let userId = "userId"
    static let orderId = "orderId"
    static let from = "from"
}

// 传参
YFRouter.push("/user/profile", params: [
    RouteParams.userId: "123",
    RouteParams.from: "home"
])

// 取参
let userId = yf_stringParam(RouteParams.userId)
```

---

## 完整示例

```swift
// ========== 1. 配置 (AppDelegate) ==========

func application(_ application: UIApplication, didFinishLaunchingWithOptions...) -> Bool {
    setupRouter()
    return true
}

func setupRouter() {
    // 配置
    YFRouter.configure { config in
        config.scheme = "myapp"
        config.onNotFound { path, _ in
            YFToast.error("页面不存在: \(path)")
        }
        config.onDidOpen { path, _, _ in
            Analytics.trackPageView(path)
        }
    }
    
    // 登录拦截
    let loginInterceptor = YFLoginInterceptor()
        .require("/user/profile", "/order/list")
        .checkLogin { UserManager.shared.isLoggedIn }
        .whenNeedLogin { _, _ in YFRouter.present("/login") }
    
    YFRouter.shared.config.addInterceptor(loginInterceptor)
    
    // 注册路由
    YFRouter.register([
        HomeViewController.self,
        UserProfileViewController.self,
        OrderListViewController.self,
        LoginViewController.self
    ])
}

// ========== 2. 页面实现 ==========

class UserProfileViewController: UIViewController, YFRoutable {
    
    static var routePath: String { "/user/profile" }
    
    private var userId: String?
    
    static func instance(with params: [String: Any]?) -> Self? {
        let vc = Self.init()
        vc.userId = params?["userId"] as? String
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData(userId: userId)
    }
}

// ========== 3. 使用路由 ==========

class HomeViewController: UIViewController {
    
    @objc func goToProfile() {
        YFRouter.push("/user/profile", params: ["userId": "123"])
    }
    
    @objc func showLogin() {
        YFRouter.present("/login")
    }
    
    @objc func goBack() {
        YFRouter.pop()
    }
}
```

---

## 高级配置

### 调试日志

```swift
YFRouter.configure { config in
    #if DEBUG
    config.enableLog = true  // 开启调试日志
    #endif
}
```

日志输出示例：
```
✅ [YFRouter] 注册路由: /user/profile → UserProfileViewController
🚀 [YFRouter] 尝试打开: /user/profile, 参数: ["userId": "123"]
✅ [YFRouter] 打开成功: /user/profile
```

### Push 失败降级

当没有 NavigationController 时，Push 会自动降级为 Present：

```swift
YFRouter.configure { config in
    config.fallbackToPresent = true  // 默认开启
}
```

### 自定义导航控制器

使用项目中的自定义导航控制器：

```swift
YFRouter.configure { config in
    config.navigationControllerClass = YFNavigationController.self
}
```

### 路由失败回调

```swift
YFRouter.configure { config in
    config.onDidFail { path, params, reason in
        switch reason {
        case .notFound:
            print("页面未注册")
        case .intercepted(let name):
            print("被拦截器拦截: \(name)")
        case .instanceFailed:
            print("页面创建失败")
        case .navigateFailed:
            print("导航失败")
        }
    }
}
```

### 线程安全

路由表的读写操作已加锁保护，支持多线程并发注册和查询。

### URL 中文支持

自动处理 URL 中的中文参数：

```swift
// ✅ 支持中文
YFRouter.open(url: "myapp://search?keyword=苹果手机")
```

### 参数类型自动转换

URL 参数会自动转换类型：

```swift
// URL: myapp://user?id=123&enabled=true
// 解析结果:
// id: Int = 123
// enabled: Bool = true
```

---

## License

MIT License
