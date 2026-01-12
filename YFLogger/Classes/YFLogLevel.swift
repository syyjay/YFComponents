//
//  YFLogLevel.swift
//  YFLogger
//
//  日志级别定义
//

import Foundation

/// 日志级别
public enum YFLogLevel: Int, Comparable, CaseIterable {
    /// 详细调试信息（仅开发环境）
    case verbose = 0
    /// 调试信息
    case debug = 1
    /// 一般信息
    case info = 2
    /// 警告信息
    case warning = 3
    /// 错误信息
    case error = 4
    /// 关闭日志
    case off = 5
    
    /// 级别图标
    public var icon: String {
        switch self {
        case .verbose: return "📝"
        case .debug:   return "🔍"
        case .info:    return "ℹ️"
        case .warning: return "⚠️"
        case .error:   return "❌"
        case .off:     return ""
        }
    }
    
    /// 级别名称
    public var name: String {
        switch self {
        case .verbose: return "VERBOSE"
        case .debug:   return "DEBUG"
        case .info:    return "INFO"
        case .warning: return "WARNING"
        case .error:   return "ERROR"
        case .off:     return "OFF"
        }
    }
    
    /// 简短名称
    public var shortName: String {
        switch self {
        case .verbose: return "V"
        case .debug:   return "D"
        case .info:    return "I"
        case .warning: return "W"
        case .error:   return "E"
        case .off:     return "-"
        }
    }
    
    // MARK: - Comparable
    
    public static func < (lhs: YFLogLevel, rhs: YFLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
