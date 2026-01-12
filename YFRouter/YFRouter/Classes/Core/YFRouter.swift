//
//  YFRouter.swift
//  YFRouter
//
//  核心路由器
//

import UIKit
import YFLogger

/// 路由器
public class YFRouter {
    
    // MARK: - 单例
    
    public static let shared = YFRouter()
    private init() {}
    
    // MARK: - 属性
    
    /// 路由配置
    public var config = YFRouterConfig()
    
    /// 已注册的路由表：路径 → 页面类型
    private var routes: [String: YFRoutable.Type] = [:]
    
    /// 自定义处理器：路径 → 创建闭包
    private var handlers: [String: ([String: Any]?) -> UIViewController?] = [:]
    
    /// 并发队列（读写锁）
    private let queue = DispatchQueue(label: "com.yf.router", attributes: .concurrent)
    
    // MARK: - 线程安全读写
    
    /// 同步读取（允许并发）
    private func read<T>(_ block: () -> T) -> T {
        queue.sync { block() }
    }
    
    /// 异步写入（独占队列）
    private func write(_ block: @escaping () -> Void) {
        queue.async(flags: .barrier) { block() }
    }
    
    /// 同步写入（独占队列，等待完成）
    private func writeSync(_ block: () -> Void) {
        queue.sync(flags: .barrier) { block() }
    }
    
    // MARK: - 配置
    
    /// 配置路由器
    public static func configure(_ block: (YFRouterConfig) -> Void) {
        block(shared.config)
    }
    
    // MARK: - 注册
    
    /// 注册页面（实现 YFRoutable 协议）
    public static func register(_ routable: YFRoutable.Type) {
        let path = routable.routePath
        shared.writeSync {
            if shared.routes[path] != nil {
                log("⚠️ [YFRouter] 路径已注册，将被覆盖: \(path)")
            }
            shared.routes[path] = routable
        }
        log("✅ [YFRouter] 注册路由: \(path) → \(routable)")
    }
    
    /// 批量注册页面
    public static func register(_ routables: [YFRoutable.Type]) {
        routables.forEach { register($0) }
    }
    
    /// 注册自定义处理器
    public static func register(_ path: String, handler: @escaping ([String: Any]?) -> UIViewController?) {
        shared.writeSync {
            if shared.handlers[path] != nil || shared.routes[path] != nil {
                log("⚠️ [YFRouter] 路径已注册，将被覆盖: \(path)")
            }
            shared.handlers[path] = handler
        }
        log("✅ [YFRouter] 注册路由: \(path) → [Handler]")
    }
    
    /// 检查路径是否已注册
    public static func isRegistered(_ path: String) -> Bool {
        shared.read { shared.routes[path] != nil || shared.handlers[path] != nil }
    }
    
    /// 注销路由
    public static func unregister(_ path: String) {
        shared.writeSync {
            shared.routes.removeValue(forKey: path)
            shared.handlers.removeValue(forKey: path)
        }
        log("🗑️ [YFRouter] 注销路由: \(path)")
    }
    
    // MARK: - 跳转
    
    /// 打开页面
    /// - Parameters:
    ///   - path: 路由路径
    ///   - params: 参数
    ///   - type: 导航方式
    ///   - animated: 是否动画
    /// - Returns: 是否成功
    @discardableResult
    public static func open(
        _ path: String,
        params: [String: Any]? = nil,
        type: YFNavigateType = .push,
        animated: Bool? = nil
    ) -> Bool {
        log("🚀 [YFRouter] 尝试打开: \(path), 参数: \(params ?? [:])")
        
        // 1. 执行拦截器检查
        for interceptor in shared.config.interceptors {
            if !interceptor.shouldOpen(path: path, params: params) {
                log("🚫 [YFRouter] 被拦截: \(path), 拦截器: \(interceptor.name)")
                interceptor.onIntercepted(path: path, params: params)
                shared.config.didFailHandler?(path, params, .intercepted(by: interceptor.name))
                return false
            }
        }
        
        // 2. 获取目标页面
        guard let viewController = viewController(for: path, params: params) else {
            log("❌ [YFRouter] 页面未找到: \(path)")
            shared.config.notFoundHandler?(path, params)
            shared.config.didFailHandler?(path, params, .notFound)
            return false
        }
        
        // 3. 执行导航
        let anim = animated ?? shared.config.defaultAnimated
        let success = YFNavigator.navigate(
            to: viewController,
            type: type,
            animated: anim,
            fallbackToPresent: shared.config.fallbackToPresent,
            navClass: shared.config.navigationControllerClass
        )
        
        if success {
            log("✅ [YFRouter] 打开成功: \(path)")
            shared.config.didOpenHandler?(path, params, viewController)
        } else {
            log("❌ [YFRouter] 导航失败: \(path)")
            shared.config.didFailHandler?(path, params, .navigateFailed)
        }
        
        return success
    }
    
    /// 通过 URL 打开页面
    @discardableResult
    public static func open(
        url: String,
        type: YFNavigateType = .push,
        animated: Bool? = nil
    ) -> Bool {
        guard let result = parseURL(url) else {
            log("❌ [YFRouter] URL 解析失败: \(url)")
            return false
        }
        return open(result.path, params: result.params, type: type, animated: animated)
    }
    
    /// 处理外部 URL（用于 AppDelegate / SceneDelegate）
    @discardableResult
    public static func handleURL(_ url: URL) -> Bool {
        return open(url: url.absoluteString)
    }
    
    // MARK: - 获取页面实例
    
    /// 获取页面实例（不执行跳转）
    public static func viewController(for path: String, params: [String: Any]? = nil) -> UIViewController? {
        // 读取路由表（线程安全）
        let (routableType, handler) = shared.read {
            (shared.routes[path], shared.handlers[path])
        }
        
        // 优先查找注册的 Routable 页面
        if let routableType = routableType {
            let vc = routableType.instance(with: params)
            vc?.yf_routeParams = params
            return vc
        }
        // 查找自定义处理器
        if let handler = handler {
            let vc = handler(params)
            vc?.yf_routeParams = params
            return vc
        }
        return nil
    }
    
    // MARK: - 便捷导航方法
    
    /// Push 页面
    @discardableResult
    public static func push(_ path: String, params: [String: Any]? = nil, animated: Bool = true) -> Bool {
        return open(path, params: params, type: .push, animated: animated)
    }
    
    /// Present 页面
    @discardableResult
    public static func present(_ path: String, params: [String: Any]? = nil, animated: Bool = true) -> Bool {
        return open(path, params: params, type: .present, animated: animated)
    }
    
    /// Present 全屏页面
    @discardableResult
    public static func presentFullScreen(_ path: String, params: [String: Any]? = nil, animated: Bool = true) -> Bool {
        return open(path, params: params, type: .presentFullScreen, animated: animated)
    }
    
    /// Pop 返回
    public static func pop(animated: Bool = true) {
        YFNavigator.pop(animated: animated)
    }
    
    /// Pop 到根视图
    public static func popToRoot(animated: Bool = true) {
        YFNavigator.popToRoot(animated: animated)
    }
    
    /// Dismiss
    public static func dismiss(animated: Bool = true) {
        YFNavigator.dismiss(animated: animated)
    }
    
    // MARK: - URL 解析
    
    /// 解析 URL 为路径和参数
    /// 支持格式：
    /// - myapp://user/profile?id=123  → path: /user/profile, params: {id: 123}
    /// - /user/profile?id=123         → path: /user/profile, params: {id: 123}
    private static func parseURL(_ urlString: String) -> (path: String, params: [String: Any]?)? {
        // 处理中文编码
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) ?? URL(string: urlString) else {
            return nil
        }
        
        // 提取路径：host + path
        // 例如 myapp://user/profile → host="user", path="/profile" → 拼接为 "/user/profile"
        var path: String
        if let host = url.host, !host.isEmpty {
            path = "/" + host + url.path
        } else {
            path = url.path
        }
        
        // 确保路径以 / 开头
        if !path.hasPrefix("/") {
            path = "/" + path
        }
        
        // 提取参数
        var params: [String: Any] = [:]
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                // 解码参数值
                let value = item.value?.removingPercentEncoding ?? item.value ?? ""
                // 尝试转换为 Bool 或 Int
                if let boolValue = Bool(value.lowercased()) {
                    params[item.name] = boolValue
                } else if let intValue = Int(value) {
                    params[item.name] = intValue
                } else {
                    params[item.name] = value
                }
            }
        }
        
        return (path, params.isEmpty ? nil : params)
    }
    
    // MARK: - 日志
    
    private static func log(_ message: String) {
        guard shared.config.enableLog else { return }
        logD("[Router] \(message)")
    }
}

// MARK: - Bool 扩展

private extension Bool {
    init?(_ string: String) {
        switch string {
        case "true", "1", "yes": self = true
        case "false", "0", "no": self = false
        default: return nil
        }
    }
}
