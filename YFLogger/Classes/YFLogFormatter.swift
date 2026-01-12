//
//  YFLogFormatter.swift
//  YFLogger
//
//  日志格式化
//

import Foundation

/// 日志格式化器
public class YFLogFormatter {
    
    private let config: YFLogConfig
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = config.dateFormat
        return formatter
    }()
    
    public init(config: YFLogConfig) {
        self.config = config
    }
    
    /// 格式化日志
    public func format(
        level: YFLogLevel,
        message: String,
        file: String,
        function: String,
        line: Int
    ) -> String {
        var components: [String] = []
        
        // 前缀
        if !config.prefix.isEmpty {
            components.append(config.prefix)
        }
        
        // 时间戳
        if config.showTimestamp {
            components.append(dateFormatter.string(from: Date()))
        }
        
        // 级别
        if config.showIcon {
            components.append(level.icon)
        }
        if config.showLevelName {
            components.append("[\(level.shortName)]")
        }
        
        // 文件位置
        if config.showFileName || config.showLineNumber {
            var location = ""
            if config.showFileName {
                let fileName = (file as NSString).lastPathComponent
                location += fileName
            }
            if config.showLineNumber {
                location += ":\(line)"
            }
            components.append(location)
        }
        
        // 函数名
        if config.showFunctionName {
            components.append(function)
        }
        
        // 消息
        components.append(message)
        
        return components.joined(separator: config.separator)
    }
}
