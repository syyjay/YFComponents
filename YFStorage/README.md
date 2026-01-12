# YFStorage

轻量级 iOS 数据存储封装库，提供统一的数据存储接口。

## 安装

```ruby
pod 'YFStorage', :path => './Components/YFStorage'
```

## 模块概览

| 模块 | 存储位置 | 适用场景 | 特点 |
|------|----------|----------|------|
| **YFDefaults** | UserDefaults | 配置、用户偏好 | 轻量、同步、永久保存 |
| **YFKeychain** | Keychain | 敏感数据（Token、密码） | 加密、安全、永久保存 |
| **YFCache** | Caches 目录 | 可重建的缓存 | 大文件、支持过期、可被系统清理 |

---

## YFDefaults

UserDefaults 的类型安全封装。

### 基础用法

```swift
import YFStorage

// 存储
YFDefaults.set("张三", forKey: "username")
YFDefaults.set(25, forKey: "age")
YFDefaults.set(true, forKey: "isVIP")

// 读取（泛型）
let name: String? = YFDefaults.get("username")
let age: Int? = YFDefaults.get("age")

// 读取（带默认值）
let count = YFDefaults.get("count", default: 0)

// 便捷方法
let name = YFDefaults.string("username")     // String?
let age = YFDefaults.int("age")              // Int (默认 0)
let score = YFDefaults.double("score")       // Double (默认 0.0)
let isVIP = YFDefaults.bool("isVIP")         // Bool (默认 false)
let data = YFDefaults.data("avatar")         // Data?

// 删除
YFDefaults.remove("username")

// 检查是否存在
if YFDefaults.contains("username") { ... }

// 清除所有
YFDefaults.removeAll()
```

### Codable 对象存储

```swift
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

// 存储对象
let user = User(id: 1, name: "张三", email: "test@example.com")
YFDefaults.set(user, forKey: "currentUser")

// 读取对象
if let user: User = YFDefaults.model("currentUser") {
    print(user.name)
}
```

### 属性包装器

```swift
class Settings {
    // 带默认值
    @YFDefault("isFirstLaunch", defaultValue: true)
    static var isFirstLaunch: Bool
    
    @YFDefault("fontSize", defaultValue: 16)
    static var fontSize: Int
    
    // 可选值
    @YFDefaultOptional("lastLoginDate")
    static var lastLoginDate: Date?
}

// 使用
Settings.isFirstLaunch = false
print(Settings.fontSize) // 16
```

### ⚠️ 注意事项

1. **不要存储敏感数据** - UserDefaults 是明文存储，敏感数据请使用 `YFKeychain`
2. **不要存储大数据** - UserDefaults 适合小量数据，大文件请使用 `YFCache`
3. **同步写入** - `set` 操作是同步的，大量写入可能影响性能
4. **数据类型** - 支持 Property List 类型：String、Int、Double、Bool、Data、Date、Array、Dictionary

---

## YFKeychain

Keychain 敏感数据存储封装。

### 基础用法

```swift
import YFStorage

// 存储
YFKeychain.set("my_secret_token", forKey: "accessToken")

// 读取
if let token = YFKeychain.get("accessToken") {
    print("Token: \(token)")
}

// 删除
YFKeychain.delete("accessToken")

// 检查是否存在
if YFKeychain.contains("accessToken") { ... }

// 清除当前 Service 下所有数据
YFKeychain.removeAll()
```

### Data 存储

```swift
// 存储 Data
let imageData = UIImage(named: "avatar")?.pngData()
YFKeychain.set(imageData!, forKey: "avatarData")

// 读取 Data
if let data = YFKeychain.getData("avatarData") {
    let image = UIImage(data: data)
}
```

### Codable 对象

```swift
struct Credentials: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
}

// 存储
let credentials = Credentials(...)
YFKeychain.set(credentials, forKey: "credentials")

// 读取
if let credentials: Credentials = YFKeychain.model("credentials") {
    print(credentials.accessToken)
}
```

### Service 分组

```swift
// 使用自定义 Service 分组存储
YFKeychain.set("value1", forKey: "key1", service: "com.app.auth")
YFKeychain.set("value2", forKey: "key2", service: "com.app.payment")

// 读取时指定 Service
let value = YFKeychain.get("key1", service: "com.app.auth")

// 只清除指定 Service
YFKeychain.removeAll(service: "com.app.auth")

// 修改默认 Service
YFKeychain.defaultService = "com.myapp.keychain"
```

### ⚠️ 注意事项

1. **自动加密** - Keychain 数据由系统自动加密，无需额外处理
2. **跨 App 共享** - 需要配置 Keychain Sharing Capability 和相同的 Access Group
3. **卸载不清除** - Keychain 数据在 App 卸载后**不会被删除**（iOS 10.3+）
4. **访问控制** - 默认使用 `kSecAttrAccessibleAfterFirstUnlock`，设备首次解锁后可访问
5. **模拟器限制** - 模拟器上 Keychain 行为可能与真机不同

---

## YFCache

磁盘缓存，支持过期时间。

### 基础用法

```swift
import YFStorage

// 存储 Data
let imageData = downloadedImage.pngData()!
YFCache.set(imageData, forKey: "image_001")

// 读取 Data
if let data = YFCache.get("image_001") {
    let image = UIImage(data: data)
}

// 删除
YFCache.remove("image_001")

// 检查是否存在
if YFCache.contains("image_001") { ... }
```

### 过期时间

```swift
// 支持多种过期方式
YFCache.set(data, forKey: "key1", expiry: .seconds(60))      // 60秒后过期
YFCache.set(data, forKey: "key2", expiry: .minutes(30))      // 30分钟后过期
YFCache.set(data, forKey: "key3", expiry: .hours(2))         // 2小时后过期
YFCache.set(data, forKey: "key4", expiry: .days(7))          // 7天后过期
YFCache.set(data, forKey: "key5", expiry: .date(someDate))   // 指定日期过期
YFCache.set(data, forKey: "key6", expiry: .never)            // 永不过期（默认）

// 读取时自动检查过期
let data = YFCache.get("key1")  // 如果已过期，返回 nil 并自动删除
```

### Codable 对象

```swift
struct Article: Codable {
    let id: Int
    let title: String
    let content: String
}

// 存储
let article = Article(id: 1, title: "Hello", content: "...")
YFCache.set(article, forKey: "article_1", expiry: .days(1))

// 读取
if let article: Article = YFCache.model("article_1") {
    print(article.title)
}
```

### 缓存管理

```swift
// 清除过期缓存
YFCache.removeExpired()

// 清除所有缓存
YFCache.removeAll()

// 获取缓存大小
let size = YFCache.shared.totalSize  // 字节数
let formatted = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
print("缓存大小: \(formatted)")  // 例如: "1.2 MB"
```

### 多实例

```swift
// 创建独立的缓存实例
let imageCache = YFCache(name: "Images")
let apiCache = YFCache(name: "APIResponse")

imageCache.set(imageData, forKey: "avatar")
apiCache.set(responseData, forKey: "userList", expiry: .minutes(5))
```

### ⚠️ 注意事项

1. **⚠️ 可被系统清理** - 存储在 Caches 目录，系统空间不足时会自动清理
2. **不会备份** - 不会被 iCloud/iTunes 备份
3. **适用场景**：
   - ✅ 网络请求缓存
   - ✅ 图片缓存
   - ✅ 临时文件
   - ❌ 用户创建的重要文档（应使用 Documents 目录）
4. **线程安全** - 内部使用并发队列，可在任意线程调用
5. **Key 编码** - Key 会自动进行 Base64 编码作为文件名

---

## 选择指南

```
需要存储什么数据？
    │
    ├─ 敏感数据（Token、密码、密钥）
    │   └─ 使用 YFKeychain ✅
    │
    ├─ 用户配置、偏好设置
    │   └─ 使用 YFDefaults ✅
    │
    ├─ 可重新获取的缓存（图片、API响应）
    │   └─ 使用 YFCache ✅
    │
    └─ 用户创建的重要文档
        └─ 需要使用 Documents 目录（YFStorage 暂不支持）
```

---

## 完整示例

```swift
import YFStorage

class UserManager {
    
    // 用户配置
    @YFDefault("isFirstLaunch", defaultValue: true)
    static var isFirstLaunch: Bool
    
    // 登录
    static func login(token: String, user: User) {
        // Token 存 Keychain（敏感）
        YFKeychain.set(token, forKey: "accessToken")
        
        // 用户信息存 Defaults（普通）
        YFDefaults.set(user, forKey: "currentUser")
        
        // 头像存 Cache（可重建）
        if let avatarData = downloadAvatar(user.avatarURL) {
            YFCache.set(avatarData, forKey: "avatar_\(user.id)", expiry: .days(7))
        }
    }
    
    // 登出
    static func logout() {
        YFKeychain.delete("accessToken")
        YFDefaults.remove("currentUser")
        YFCache.removeAll()
    }
    
    // 获取当前用户
    static var currentUser: User? {
        YFDefaults.model("currentUser")
    }
    
    // 获取 Token
    static var accessToken: String? {
        YFKeychain.get("accessToken")
    }
}
```

---

## API 速查

### YFDefaults

| 方法 | 说明 |
|------|------|
| `set(_:forKey:)` | 存储值 |
| `get(_:)` | 获取值（泛型） |
| `get(_:default:)` | 获取值（带默认值） |
| `string/int/double/bool/data(_:)` | 便捷获取方法 |
| `set(_:forKey:)` (Encodable) | 存储 Codable 对象 |
| `model(_:type:)` | 获取 Codable 对象 |
| `remove(_:)` | 删除 |
| `contains(_:)` | 是否存在 |
| `removeAll()` | 清除所有 |

### YFKeychain

| 方法 | 说明 |
|------|------|
| `set(_:forKey:service:)` | 存储字符串 |
| `get(_:service:)` | 获取字符串 |
| `set(_:forKey:service:)` (Data) | 存储 Data |
| `getData(_:service:)` | 获取 Data |
| `set(_:forKey:service:)` (Encodable) | 存储 Codable 对象 |
| `model(_:type:service:)` | 获取 Codable 对象 |
| `delete(_:service:)` | 删除 |
| `contains(_:service:)` | 是否存在 |
| `removeAll(service:)` | 清除所有 |

### YFCache

| 方法 | 说明 |
|------|------|
| `set(_:forKey:expiry:)` | 存储 Data |
| `get(_:)` | 获取 Data |
| `set(_:forKey:expiry:)` (Encodable) | 存储 Codable 对象 |
| `model(_:type:)` | 获取 Codable 对象 |
| `remove(_:)` | 删除 |
| `contains(_:)` | 是否存在 |
| `removeExpired()` | 清除过期缓存 |
| `removeAll()` | 清除所有缓存 |
| `totalSize` | 缓存大小（字节） |

### YFCacheExpiry

| 值 | 说明 |
|------|------|
| `.never` | 永不过期 |
| `.seconds(TimeInterval)` | N 秒后过期 |
| `.minutes(Int)` | N 分钟后过期 |
| `.hours(Int)` | N 小时后过期 |
| `.days(Int)` | N 天后过期 |
| `.date(Date)` | 指定日期过期 |
