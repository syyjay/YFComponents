//
//  YFLogger.swift
//  YFLogger
//
//  核心日志类
//

import Foundation

/// 日志管理器
public class YFLogger {
    
    // MARK: - 单例
    
    public static let shared = YFLogger()
    private init() {}
    
    // MARK: - 属性
    
    /// 配置
    public var config = YFLogConfig() {
        didSet {
            formatter = YFLogFormatter(config: config)
            if config.fileEnabled {
                fileWriter = YFLogFileWriter(config: config)
            }
        }
    }
    
    private lazy var formatter = YFLogFormatter(config: config)
    private lazy var fileWriter: YFLogFileWriter? = nil
    
    // MARK: - 配置
    
    /// 配置日志
    public static func configure(_ block: (YFLogConfig) -> Void) {
        let config = YFLogConfig()
        block(config)
        shared.config = config
    }
    
    /// 使用预设配置
    public static func configure(with config: YFLogConfig) {
        shared.config = config
    }
    
    // MARK: - 日志方法
    
    /// 详细日志
    public static func verbose(
        _ message: @autoclosure () -> Any,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(.verbose, message: message(), file: file, function: function, line: line)
    }
    
    /// 调试日志
    public static func debug(
        _ message: @autoclosure () -> Any,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(.debug, message: message(), file: file, function: function, line: line)
    }
    
    /// 信息日志
    public static func info(
        _ message: @autoclosure () -> Any,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(.info, message: message(), file: file, function: function, line: line)
    }
    
    /// 警告日志
    public static func warning(
        _ message: @autoclosure () -> Any,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(.warning, message: message(), file: file, function: function, line: line)
    }
    
    /// 错误日志
    public static func error(
        _ message: @autoclosure () -> Any,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(.error, message: message(), file: file, function: function, line: line)
    }
    
    // MARK: - 文件管理
    
    /// 获取日志文件列表
    public static func getLogFiles() -> [URL] {
        shared.fileWriter?.getLogFiles() ?? []
    }
    
    /// 清理所有日志文件
    public static func clearLogs() {
        shared.fileWriter?.clearLogs()
    }
    
    // MARK: - Private
    
    private func log(
        _ level: YFLogLevel,
        message: @autoclosure () -> Any,
        file: String,
        function: String,
        line: Int
    ) {
        // 级别过滤
        guard level >= config.minLevel else { return }
        
        // 格式化消息
        let messageString = String(describing: message())
        let formattedMessage = formatter.format(
            level: level,
            message: messageString,
            file: file,
            function: function,
            line: line
        )
        
        // 控制台输出
        if config.consoleEnabled {
            print(formattedMessage)
        }
        
        // 文件输出
        if config.fileEnabled {
            fileWriter?.write(formattedMessage)
        }
    }
}

// MARK: - 便捷全局函数

/// 详细日志
public func logV(_ message: @autoclosure () -> Any, file: String = #file, function: String = #function, line: Int = #line) {
    YFLogger.verbose(message(), file: file, function: function, line: line)
}

/// 调试日志
public func logD(_ message: @autoclosure () -> Any, file: String = #file, function: String = #function, line: Int = #line) {
    YFLogger.debug(message(), file: file, function: function, line: line)
}

/// 信息日志
public func logI(_ message: @autoclosure () -> Any, file: String = #file, function: String = #function, line: Int = #line) {
    YFLogger.info(message(), file: file, function: function, line: line)
}

/// 警告日志
public func logW(_ message: @autoclosure () -> Any, file: String = #file, function: String = #function, line: Int = #line) {
    YFLogger.warning(message(), file: file, function: function, line: line)
}

/// 错误日志
public func logE(_ message: @autoclosure () -> Any, file: String = #file, function: String = #function, line: Int = #line) {
    YFLogger.error(message(), file: file, function: function, line: line)
}
