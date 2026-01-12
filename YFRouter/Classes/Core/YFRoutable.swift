//
//  YFRoutable.swift
//  YFRouter
//
//  可路由协议
//

import UIKit

/// 可路由协议
/// 页面需要实现此协议才能被路由器管理
public protocol YFRoutable: UIViewController {
    
    /// 路由路径（唯一标识）
    /// 建议使用 "/" 开头的路径格式，如 "/user/profile"
    static var routePath: String { get }
    
    /// 通过参数创建页面实例
    /// - Parameter params: 路由参数
    /// - Returns: 页面实例，返回 nil 表示创建失败
    static func instance(with params: [String: Any]?) -> Self?
}

/// 默认实现
public extension YFRoutable {
    
    /// 默认使用无参初始化
    static func instance(with params: [String: Any]?) -> Self? {
        let vc = Self.init()
        vc.yf_routeParams = params
        return vc
    }
}

// MARK: - 参数存储

private var kRouteParamsKey: UInt8 = 0

public extension UIViewController {
    
    /// 路由传递的参数
    var yf_routeParams: [String: Any]? {
        get { objc_getAssociatedObject(self, &kRouteParamsKey) as? [String: Any] }
        set { objc_setAssociatedObject(self, &kRouteParamsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 获取指定类型的参数
    func yf_param<T>(_ key: String) -> T? {
        return yf_routeParams?[key] as? T
    }
    
    /// 获取字符串参数
    func yf_stringParam(_ key: String) -> String? {
        if let value = yf_routeParams?[key] {
            return "\(value)"
        }
        return nil
    }
    
    /// 获取整数参数
    func yf_intParam(_ key: String) -> Int? {
        if let value = yf_routeParams?[key] as? Int {
            return value
        }
        if let str = yf_routeParams?[key] as? String {
            return Int(str)
        }
        return nil
    }
}
