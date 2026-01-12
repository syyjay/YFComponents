//
//  YFNetworkConfig.swift
//  YFNetwork
//
//  网络配置
//

import Foundation

/// 网络配置
public final class YFNetworkConfig {
    
    public static let shared = YFNetworkConfig()
    private init() {}
    
    /// BaseURL
    public var baseURL: String = ""
    
    /// 通用请求头
    public var headers: [String: String] = [
        "Content-Type": "application/json"
    ]
    
    /// 是否打印日志
    public var enableLog: Bool = true
    
    /// JSON 解码器
    public lazy var decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()
}
