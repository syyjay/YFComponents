//
//  YFRouterInterceptor.swift
//  YFRouter
//
//  路由拦截器
//

import UIKit

/// 路由拦截器协议
public protocol YFRouterInterceptor {
    
    /// 拦截器名称（用于调试）
    var name: String { get }
    
    /// 判断是否允许跳转
    /// - Parameters:
    ///   - path: 目标路径
    ///   - params: 路由参数
    /// - Returns: true 允许继续，false 拦截
    func shouldOpen(path: String, params: [String: Any]?) -> Bool
    
    /// 被拦截后的处理
    /// - Parameters:
    ///   - path: 目标路径
    ///   - params: 路由参数
    func onIntercepted(path: String, params: [String: Any]?)
}

/// 默认实现
public extension YFRouterInterceptor {
    var name: String { String(describing: type(of: self)) }
    func onIntercepted(path: String, params: [String: Any]?) {}
}

// MARK: - 登录拦截器

/// 登录拦截器
/// 用于拦截需要登录才能访问的页面
public class YFLoginInterceptor: YFRouterInterceptor {
    
    public var name: String { "LoginInterceptor" }
    
    /// 需要登录的路径列表
    public var requiredPaths: Set<String> = []
    
    /// 检查是否已登录
    public var isLoggedIn: (() -> Bool)?
    
    /// 未登录时的处理
    public var onNeedLogin: ((_ targetPath: String, _ params: [String: Any]?) -> Void)?
    
    public init() {}
    
    public func shouldOpen(path: String, params: [String: Any]?) -> Bool {
        // 不在需要登录的列表中，放行
        guard requiredPaths.contains(path) else { return true }
        
        // 已登录，放行
        if let isLoggedIn = isLoggedIn, isLoggedIn() {
            return true
        }
        
        // 未登录，拦截
        return false
    }
    
    public func onIntercepted(path: String, params: [String: Any]?) {
        onNeedLogin?(path, params)
    }
    
    // MARK: - 便捷配置
    
    /// 添加需要登录的路径
    @discardableResult
    public func require(_ paths: String...) -> Self {
        paths.forEach { requiredPaths.insert($0) }
        return self
    }
    
    /// 设置登录检查
    @discardableResult
    public func checkLogin(_ check: @escaping () -> Bool) -> Self {
        isLoggedIn = check
        return self
    }
    
    /// 设置未登录处理
    @discardableResult
    public func whenNeedLogin(_ handler: @escaping (_ targetPath: String, _ params: [String: Any]?) -> Void) -> Self {
        onNeedLogin = handler
        return self
    }
}

// MARK: - 权限拦截器

/// 权限拦截器
/// 用于基于角色/权限的页面访问控制
public class YFPermissionInterceptor: YFRouterInterceptor {
    
    public var name: String { "PermissionInterceptor" }
    
    /// 路径 → 所需权限的映射
    public var pathPermissions: [String: String] = [:]
    
    /// 检查是否有权限
    public var hasPermission: ((_ permission: String) -> Bool)?
    
    /// 无权限时的处理
    public var onNoPermission: ((_ path: String, _ permission: String) -> Void)?
    
    public init() {}
    
    public func shouldOpen(path: String, params: [String: Any]?) -> Bool {
        guard let requiredPermission = pathPermissions[path] else { return true }
        return hasPermission?(requiredPermission) ?? false
    }
    
    public func onIntercepted(path: String, params: [String: Any]?) {
        if let permission = pathPermissions[path] {
            onNoPermission?(path, permission)
        }
    }
}
