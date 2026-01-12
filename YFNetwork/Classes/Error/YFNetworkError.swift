//
//  YFNetworkError.swift
//  YFNetwork
//
//  网络错误
//

import Foundation
import Moya

/// 网络错误
public enum YFNetworkError: LocalizedError {
    /// Moya 错误
    case moyaError(MoyaError)
    /// 状态码错误
    case statusCode(Int, Data?)
    /// 解码失败
    case decodeFailed(Error)
    /// 无数据
    case noData
    
    public var errorDescription: String? {
        switch self {
        case .moyaError(let e):
            return e.localizedDescription
        case .statusCode(let code, _):
            return "状态码错误: \(code)"
        case .decodeFailed(let e):
            return "解码失败: \(e.localizedDescription)"
        case .noData:
            return "无数据"
        }
    }
    
    /// 响应数据
    public var data: Data? {
        switch self {
        case .statusCode(_, let d): return d
        case .moyaError(let e): return e.response?.data
        default: return nil
        }
    }
    
    /// 状态码
    public var statusCode: Int? {
        switch self {
        case .statusCode(let c, _): return c
        case .moyaError(let e): return e.response?.statusCode
        default: return nil
        }
    }
}
