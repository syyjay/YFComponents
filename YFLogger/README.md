# YFLogger

轻量级 iOS 日志框架，支持分级日志、格式化输出、文件存储。

---

## 目录

- [设计目标](#设计目标)
- [架构设计](#架构设计)
- [核心概念](#核心概念)
- [快速开始](#快速开始)
- [详细使用](#详细使用)
- [文件存储](#文件存储)
- [API 参考](#api-参考)
- [最佳实践](#最佳实践)

---

## 设计目标

### 解决的问题

**传统 `print()` 的痛点：**

```swift
// ❌ 传统方式
print("用户登录了")           // 没有时间、位置信息
print("DEBUG: \(userData)")  // 手动加前缀
print("ERROR: 请求失败")      // 无法区分级别
```

**存在的问题：**
1. **无上下文**：不知道日志来自哪个文件、哪一行
2. **无分级**：debug 和 error 混在一起，无法过滤
3. **无持久化**：App 关闭后日志丢失
4. **发布残留**：生产环境忘记删除 print

**YFLogger 方式：**

```swift
// ✅ YFLogger
logD("用户登录了")
logE("请求失败: \(error)")

// 输出：
// 14:30:25.123 | 🔍 | [D] | LoginVC.swift:42 | 用户登录了
// 14:30:25.456 | ❌ | [E] | NetworkManager.swift:128 | 请求失败: timeout
```

**优势：**
1. **丰富上下文**：自动记录时间、文件、行号
2. **分级管理**：5 个级别，可按需过滤
3. **文件存储**：支持写入文件，便于问题追踪
4. **环境隔离**：生产环境自动关闭控制台输出

---

## 架构设计

### 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                        调用层                                │
│                                                              │
│   logD("message")  →  YFLogger.debug("message")             │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│                       YFLogger (核心)                        │
│                           │                                  │
│         ┌─────────────────┼─────────────────┐                │
│         ▼                 ▼                 ▼                │
│   ┌───────────┐    ┌───────────┐    ┌───────────────┐       │
│   │ YFLogLevel│    │YFLogConfig│    │ YFLogFormatter │       │
│   │  日志级别  │    │   配置    │    │    格式化器    │       │
│   └───────────┘    └───────────┘    └───────────────┘       │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                        输出层                                │
│                           │                                  │
│         ┌─────────────────┴─────────────────┐                │
│         ▼                                   ▼                │
│   ┌───────────┐                    ┌─────────────────┐      │
│   │  Console  │                    │ YFLogFileWriter │      │
│   │ print()   │                    │    文件写入      │      │
│   └───────────┘                    └─────────────────┘      │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 目录结构

```
YFLogger/
├── YFLogger.podspec
├── LICENSE
├── README.md
└── YFLogger/
    └── Classes/
        ├── YFLogLevel.swift       # 日志级别枚举
        ├── YFLogConfig.swift      # 配置类
        ├── YFLogFormatter.swift   # 格式化器
        ├── YFLogFileWriter.swift  # 文件写入器
        └── YFLogger.swift         # 核心类 + 全局函数
```

### 模块职责

| 模块 | 职责 |
|------|------|
| **YFLogLevel** | 定义 5 个日志级别及其属性（图标、名称） |
| **YFLogConfig** | 存储配置项（级别、开关、格式、文件设置） |
| **YFLogFormatter** | 将日志信息格式化为字符串 |
| **YFLogFileWriter** | 管理日志文件的写入、轮转、清理 |
| **YFLogger** | 核心类，协调各模块，对外提供 API |

---

## 核心概念

### 1. 日志级别 (YFLogLevel)

```
┌────────┬────────┬──────┬─────────────────────────────────┐
│  级别   │  图标   │ 简称  │            用途                 │
├────────┼────────┼──────┼─────────────────────────────────┤
│ verbose│  📝    │  V   │ 详细调试信息（如变量值、循环迭代） │
│ debug  │  🔍    │  D   │ 调试信息（如函数调用、状态变化）  │
│ info   │  ℹ️    │  I   │ 一般信息（如用户操作、业务流程）  │
│ warning│  ⚠️    │  W   │ 警告信息（如网络慢、内存紧张）    │
│ error  │  ❌    │  E   │ 错误信息（如请求失败、异常捕获）  │
│ off    │  -     │  -   │ 关闭日志                        │
└────────┴────────┴──────┴─────────────────────────────────┘
```

**级别过滤原理：**
```swift
config.minLevel = .warning  // 只输出 warning 及以上

logV("不输出")  // verbose < warning ❌
logD("不输出")  // debug   < warning ❌
logI("不输出")  // info    < warning ❌
logW("输出")    // warning = warning ✅
logE("输出")    // error   > warning ✅
```

### 2. 格式化 (YFLogFormatter)

**输入：**
```swift
level: .debug
message: "用户登录"
file: "/path/to/LoginViewController.swift"
function: "loginButtonTapped()"
line: 42
```

**输出：**
```
14:30:25.123 | 🔍 | [D] | LoginViewController.swift:42 | 用户登录
```

**格式组成：**
```
┌──────────────┬────┬─────┬──────────────────────────┬──────────┐
│   时间戳      │图标│级别  │       位置信息            │   消息    │
├──────────────┼────┼─────┼──────────────────────────┼──────────┤
│ 14:30:25.123 │ 🔍 │ [D] │ LoginViewController:42   │ 用户登录  │
└──────────────┴────┴─────┴──────────────────────────┴──────────┘
```

### 3. 文件写入 (YFLogFileWriter)

**文件命名规则：**
```
log_2024-01-15.log      # 当天日志
log_2024-01-15_1.log    # 超过大小限制后的轮转文件
log_2024-01-15_2.log
log_2024-01-14.log      # 昨天的日志
```

**自动轮转机制：**
```
                    日志写入
                       │
                       ▼
              ┌────────────────┐
              │  检查日期变化   │
              └───────┬────────┘
                      │
        ┌─────────────┴─────────────┐
        ▼                           ▼
    日期相同                     日期变化
        │                           │
        ▼                           ▼
┌───────────────┐            ┌─────────────┐
│ 检查文件大小  │            │ 关闭旧文件  │
└───────┬───────┘            │ 清理过期    │
        │                    │ 创建新文件  │
   ┌────┴────┐               └─────────────┘
   ▼         ▼
 < 5MB    >= 5MB
   │         │
   ▼         ▼
 继续写   轮转文件
         (重命名为 _1, _2...)
```

### 4. 惰性求值 (@autoclosure)

**原理：**
```swift
// 使用 @autoclosure，参数变成闭包
public static func debug(_ message: @autoclosure () -> Any, ...)

// 调用时
logD("用户数据: \(expensiveOperation())")

// 实际执行：
// 1. 先检查级别
if level >= config.minLevel {
    // 2. 只有需要输出时才执行闭包
    let msg = message()  // 这时才调用 expensiveOperation()
}
```

**优势：**
```swift
config.minLevel = .error

// 这个耗时操作不会执行！
logD("数据: \(heavyComputation())")  // debug < error，跳过
```

---

## 快速开始

### 安装

```ruby
pod 'YFLogger', :path => './Components/YFLogger'
```

### 基础使用

```swift
import YFLogger

// 使用全局函数（推荐）
logV("详细信息")    // 📝 VERBOSE
logD("调试信息")    // 🔍 DEBUG
logI("一般信息")    // ℹ️ INFO
logW("警告信息")    // ⚠️ WARNING
logE("错误信息")    // ❌ ERROR

// 或使用类方法
YFLogger.debug("调试信息")
YFLogger.error("错误信息")
```

### 配置

```swift
// 在 AppDelegate 中配置
func application(_ application: UIApplication, didFinishLaunchingWithOptions...) -> Bool {
    
    #if DEBUG
    YFLogger.configure(with: .development)
    #else
    YFLogger.configure(with: .production)
    #endif
    
    return true
}
```

---

## 详细使用

### 自定义配置

```swift
YFLogger.configure { config in
    // === 前缀（方便过滤）===
    config.prefix = "[YF]"             // 日志前缀，控制台搜索 [YF] 过滤
    
    // === 级别控制 ===
    config.minLevel = .debug           // 最低输出级别
    
    // === 输出目标 ===
    config.consoleEnabled = true       // 控制台输出
    config.fileEnabled = true          // 文件存储
    
    // === 格式控制 ===
    config.showTimestamp = true        // 显示时间
    config.showIcon = true             // 显示图标
    config.showLevelName = true        // 显示级别名
    config.showFileName = true         // 显示文件名
    config.showLineNumber = true       // 显示行号
    config.showFunctionName = false    // 显示函数名
    
    // === 时间格式 ===
    config.dateFormat = "HH:mm:ss.SSS" // 时间格式
    config.separator = " | "           // 分隔符
    
    // === 文件设置 ===
    config.maxFileSize = 5 * 1024 * 1024  // 单文件最大 5MB
    config.maxFileCount = 7               // 最多保留 7 个文件
    config.filePrefix = "log"             // 文件名前缀
}
```

### 日志前缀

默认前缀为 `[YF]`，方便在 Xcode 控制台过滤日志：

```
[YF] | 14:30:25.123 | 🔍 | [D] | ViewController.swift:42 | 调试信息
[YF] | 14:30:25.124 | ❌ | [E] | NetworkManager.swift:88 | 请求失败
```

**自定义前缀：**
```swift
config.prefix = "[MyApp]"  // 自定义
config.prefix = ""         // 不要前缀
```

**过滤方式：** 在 Xcode 控制台底部搜索框输入 `[YF]` 即可只显示你的日志。

### 预设配置

```swift
// 开发环境
YFLogger.configure(with: .development)
// 等价于：
// minLevel = .verbose
// consoleEnabled = true
// fileEnabled = false
// showIcon = true
// showFileName = true
// showLineNumber = true

// 生产环境
YFLogger.configure(with: .production)
// 等价于：
// minLevel = .warning
// consoleEnabled = false
// fileEnabled = true
// showIcon = false
// showFileName = false
// showLineNumber = false
```

### 条件编译

```swift
#if DEBUG
logD("这条只在 Debug 模式输出")
#endif

// 或者通过配置控制
#if DEBUG
YFLogger.shared.config.minLevel = .verbose
#else
YFLogger.shared.config.minLevel = .error
#endif
```

---

## 文件存储

### 启用文件存储

```swift
YFLogger.configure { config in
    config.fileEnabled = true
    config.maxFileSize = 5 * 1024 * 1024  // 5MB
    config.maxFileCount = 7               // 7 天
}
```

### 文件位置

```
{App Sandbox}/Library/Caches/Logs/
├── log_2024-01-15.log       # 今天
├── log_2024-01-14.log       # 昨天
├── log_2024-01-13.log       # 前天
└── ...
```

### 获取日志文件

```swift
// 获取所有日志文件
let files = YFLogger.getLogFiles()

for file in files {
    print("文件: \(file.lastPathComponent)")
    
    // 读取内容
    if let content = try? String(contentsOf: file) {
        print(content)
    }
}
```

### 清理日志

```swift
// 清理所有日志文件
YFLogger.clearLogs()
```

### 导出日志

```swift
// 获取日志用于分享/上传
func exportLogs() -> URL? {
    let files = YFLogger.getLogFiles()
    
    // 合并所有日志
    var allContent = ""
    for file in files {
        if let content = try? String(contentsOf: file) {
            allContent += "\n\n=== \(file.lastPathComponent) ===\n\n"
            allContent += content
        }
    }
    
    // 写入临时文件
    let tempURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("app_logs.txt")
    try? allContent.write(to: tempURL, atomically: true, encoding: .utf8)
    
    return tempURL
}
```

---

## API 参考

### YFLogger

| 方法 | 说明 |
|------|------|
| `configure(_:)` | 自定义配置 |
| `configure(with:)` | 使用预设配置 |
| `verbose(_:file:function:line:)` | 详细日志 |
| `debug(_:file:function:line:)` | 调试日志 |
| `info(_:file:function:line:)` | 信息日志 |
| `warning(_:file:function:line:)` | 警告日志 |
| `error(_:file:function:line:)` | 错误日志 |
| `getLogFiles()` | 获取日志文件列表 |
| `clearLogs()` | 清理所有日志 |

### 全局函数

| 函数 | 说明 |
|------|------|
| `logV(_:)` | 详细日志 (verbose) |
| `logD(_:)` | 调试日志 (debug) |
| `logI(_:)` | 信息日志 (info) |
| `logW(_:)` | 警告日志 (warning) |
| `logE(_:)` | 错误日志 (error) |

### YFLogLevel

| 级别 | 值 | 图标 | 说明 |
|------|----|------|------|
| `.verbose` | 0 | 📝 | 详细调试 |
| `.debug` | 1 | 🔍 | 调试信息 |
| `.info` | 2 | ℹ️ | 一般信息 |
| `.warning` | 3 | ⚠️ | 警告 |
| `.error` | 4 | ❌ | 错误 |
| `.off` | 5 | - | 关闭 |

### YFLogConfig

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `prefix` | `String` | `"[YF]"` | 日志前缀（方便过滤） |
| `minLevel` | `YFLogLevel` | `.verbose` | 最低输出级别 |
| `consoleEnabled` | `Bool` | `true` | 控制台输出 |
| `fileEnabled` | `Bool` | `false` | 文件存储 |
| `logDirectory` | `URL?` | `Caches/Logs` | 日志目录 |
| `filePrefix` | `String` | `"log"` | 文件名前缀 |
| `maxFileSize` | `UInt64` | 5MB | 单文件最大 |
| `maxFileCount` | `Int` | 7 | 保留文件数 |
| `showTimestamp` | `Bool` | `true` | 显示时间 |
| `showIcon` | `Bool` | `true` | 显示图标 |
| `showLevelName` | `Bool` | `true` | 显示级别 |
| `showFileName` | `Bool` | `true` | 显示文件名 |
| `showLineNumber` | `Bool` | `true` | 显示行号 |
| `showFunctionName` | `Bool` | `false` | 显示函数名 |
| `dateFormat` | `String` | `"HH:mm:ss.SSS"` | 时间格式 |
| `separator` | `String` | `" \| "` | 分隔符 |

---

## 最佳实践

### 1. 选择正确的级别

```swift
// ✅ 正确使用
logV("循环第 \(i) 次迭代")        // 极详细，开发时用
logD("loadUserData() 开始")       // 调试流程
logI("用户 \(userId) 登录成功")   // 重要业务事件
logW("网络请求超时，正在重试")     // 需要关注但不致命
logE("数据库写入失败: \(error)")  // 需要处理的错误

// ❌ 错误使用
logE("用户点击了按钮")            // 这不是错误
logD("严重错误！")                // 错误应该用 logE
```

### 2. 环境区分

```swift
// AppDelegate.swift
func setupLogger() {
    #if DEBUG
    YFLogger.configure { config in
        config.minLevel = .verbose
        config.consoleEnabled = true
        config.fileEnabled = false
    }
    #else
    YFLogger.configure { config in
        config.minLevel = .warning
        config.consoleEnabled = false
        config.fileEnabled = true
    }
    #endif
}
```

### 3. 敏感信息处理

```swift
// ❌ 不要记录敏感信息
logD("用户密码: \(password)")
logI("Token: \(accessToken)")

// ✅ 脱敏处理
logD("用户密码: ****")
logI("Token: \(token.prefix(10))...")
```

### 4. 结构化日志

```swift
// ❌ 难以解析
logI("用户 123 购买了商品 456，价格 99.9")

// ✅ 易于解析
logI("[Order] userId=123, productId=456, price=99.9")

// 或使用 JSON
let info = ["userId": 123, "productId": 456, "price": 99.9]
logI("[Order] \(info)")
```

### 5. 错误日志包含堆栈

```swift
do {
    try riskyOperation()
} catch {
    // ✅ 包含完整错误信息
    logE("操作失败: \(error.localizedDescription)")
    logE("详细: \(error)")
}
```

---

## 与其他日志框架对比

| 特性 | YFLogger | CocoaLumberjack | SwiftyBeaver |
|------|----------|-----------------|--------------|
| 轻量级 | ✅ | ❌ | ❌ |
| 无依赖 | ✅ | ✅ | ✅ |
| 分级日志 | ✅ | ✅ | ✅ |
| 文件存储 | ✅ | ✅ | ✅ |
| 控制台着色 | ✅ | ✅ | ✅ |
| 云端上传 | ❌ | ❌ | ✅ |
| 代码行数 | ~400 | ~5000 | ~3000 |

**YFLogger 的定位：** 轻量、够用、易于定制。

---

## License

MIT License
