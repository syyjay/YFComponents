//
//  YFRouterConfig.swift
//  YFRouter
//
//  路由配置
//

import UIKit

/// 路由配置
public class YFRouterConfig {
    
    /// App 的 URL Scheme（如 "myapp"）
    /// 用于解析 DeepLink: myapp://user/profile?id=123
    public var scheme: String = ""
    
    /// 默认是否使用动画
    public var defaultAnimated: Bool = true
    
    /// 是否启用调试日志
    public var enableLog: Bool = false
    
    /// Push 失败时是否自动降级为 Present
    public var fallbackToPresent: Bool = true
    
    /// 自定义导航控制器类型（用于 presentWithNav）
    public var navigationControllerClass: UINavigationController.Type = UINavigationController.self
    
    /// 全局拦截器列表
    public var interceptors: [YFRouterInterceptor] = []
    
    /// 页面未找到时的回调
    public var notFoundHandler: ((_ path: String, _ params: [String: Any]?) -> Void)?
    
    /// 路由成功后的回调（可用于埋点）
    public var didOpenHandler: ((_ path: String, _ params: [String: Any]?, _ vc: UIViewController) -> Void)?
    
    /// 路由失败回调（拦截、未找到等）
    public var didFailHandler: ((_ path: String, _ params: [String: Any]?, _ reason: YFRouterFailReason) -> Void)?
    
    public init() {}
    
    // MARK: - 便捷方法
    
    /// 添加拦截器
    @discardableResult
    public func addInterceptor(_ interceptor: YFRouterInterceptor) -> Self {
        interceptors.append(interceptor)
        return self
    }
    
    /// 设置未找到处理
    @discardableResult
    public func onNotFound(_ handler: @escaping (_ path: String, _ params: [String: Any]?) -> Void) -> Self {
        notFoundHandler = handler
        return self
    }
    
    /// 设置路由成功回调
    @discardableResult
    public func onDidOpen(_ handler: @escaping (_ path: String, _ params: [String: Any]?, _ vc: UIViewController) -> Void) -> Self {
        didOpenHandler = handler
        return self
    }
    
    /// 设置路由失败回调
    @discardableResult
    public func onDidFail(_ handler: @escaping (_ path: String, _ params: [String: Any]?, _ reason: YFRouterFailReason) -> Void) -> Self {
        didFailHandler = handler
        return self
    }
}

/// 路由失败原因
public enum YFRouterFailReason {
    /// 页面未注册
    case notFound
    /// 被拦截器拦截
    case intercepted(by: String)
    /// 页面创建失败
    case instanceFailed
    /// 导航失败（无导航控制器等）
    case navigateFailed
}
