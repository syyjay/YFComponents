//
//  YFLogConfig.swift
//  YFLogger
//
//  日志配置
//

import Foundation

/// 日志配置
public class YFLogConfig {
    
    /// 日志前缀（方便过滤，如 "[YF]"）
    public var prefix: String = "[YF]"
    
    /// 最低日志级别（低于此级别的日志不输出）
    public var minLevel: YFLogLevel = .verbose
    
    /// 是否输出到控制台
    public var consoleEnabled: Bool = true
    
    /// 是否写入文件
    public var fileEnabled: Bool = false
    
    /// 日志文件目录
    public var logDirectory: URL?
    
    /// 日志文件名前缀
    public var filePrefix: String = "log"
    
    /// 单个日志文件最大大小（字节），默认 5MB
    public var maxFileSize: UInt64 = 5 * 1024 * 1024
    
    /// 保留的日志文件数量
    public var maxFileCount: Int = 7
    
    /// 是否显示时间
    public var showTimestamp: Bool = true
    
    /// 是否显示级别图标
    public var showIcon: Bool = true
    
    /// 是否显示级别名称
    public var showLevelName: Bool = true
    
    /// 是否显示文件名
    public var showFileName: Bool = true
    
    /// 是否显示行号
    public var showLineNumber: Bool = true
    
    /// 是否显示函数名
    public var showFunctionName: Bool = false
    
    /// 时间格式
    public var dateFormat: String = "HH:mm:ss.SSS"
    
    /// 分隔符
    public var separator: String = " | "
    
    public init() {
        // 默认日志目录
        if let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            logDirectory = cachesDir.appendingPathComponent("Logs", isDirectory: true)
        }
    }
    
    // MARK: - 便捷配置
    
    /// 开发环境配置
    public static var development: YFLogConfig {
        let config = YFLogConfig()
        config.minLevel = .verbose
        config.consoleEnabled = true
        config.fileEnabled = false
        config.showIcon = true
        config.showFileName = true
        config.showLineNumber = true
        return config
    }
    
    /// 生产环境配置
    public static var production: YFLogConfig {
        let config = YFLogConfig()
        config.minLevel = .warning
        config.consoleEnabled = false
        config.fileEnabled = true
        config.showIcon = false
        config.showFileName = false
        config.showLineNumber = false
        return config
    }
}
