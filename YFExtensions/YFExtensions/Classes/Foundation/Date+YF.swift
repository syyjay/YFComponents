//
//  Date+YF.swift
//  YFExtensions
//
//  Date 扩展
//

import Foundation

public extension Date {
    
    // MARK: - 格式化
    
    /// 格式化为字符串
    func string(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }
    
    /// 常用格式
    var dateString: String { string(format: "yyyy-MM-dd") }
    var timeString: String { string(format: "HH:mm:ss") }
    var dateTimeString: String { string(format: "yyyy-MM-dd HH:mm:ss") }
    var shortDateString: String { string(format: "MM-dd") }
    var shortTimeString: String { string(format: "HH:mm") }
    var yearMonthString: String { string(format: "yyyy-MM") }
    var chineseDateString: String { string(format: "yyyy年MM月dd日") }
    
    // MARK: - 时间戳
    
    /// 秒级时间戳
    var timestamp: Int { Int(timeIntervalSince1970) }
    
    /// 毫秒级时间戳
    var millisecondTimestamp: Int64 { Int64(timeIntervalSince1970 * 1000) }
    
    /// 从时间戳创建
    static func from(timestamp: Int) -> Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    /// 从毫秒时间戳创建
    static func from(milliseconds: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    // MARK: - 组件
    
    var year: Int { Calendar.current.component(.year, from: self) }
    var month: Int { Calendar.current.component(.month, from: self) }
    var day: Int { Calendar.current.component(.day, from: self) }
    var hour: Int { Calendar.current.component(.hour, from: self) }
    var minute: Int { Calendar.current.component(.minute, from: self) }
    var second: Int { Calendar.current.component(.second, from: self) }
    var weekday: Int { Calendar.current.component(.weekday, from: self) }
    
    /// 星期几（中文）
    var weekdayString: String {
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        return "周\(weekdays[weekday - 1])"
    }
    
    // MARK: - 判断
    
    var isToday: Bool { Calendar.current.isDateInToday(self) }
    var isYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isTomorrow: Bool { Calendar.current.isDateInTomorrow(self) }
    var isWeekend: Bool { Calendar.current.isDateInWeekend(self) }
    var isThisYear: Bool { year == Date().year }
    var isThisMonth: Bool { isThisYear && month == Date().month }
    
    var isFuture: Bool { self > Date() }
    var isPast: Bool { self < Date() }
    
    // MARK: - 计算
    
    /// 添加天数
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    /// 添加月份
    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    /// 添加年份
    func adding(years: Int) -> Date {
        Calendar.current.date(byAdding: .year, value: years, to: self) ?? self
    }
    
    /// 添加小时
    func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }
    
    /// 添加分钟
    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }
    
    /// 与另一日期相差天数
    func days(from date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    /// 当天开始时间 (00:00:00)
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// 当天结束时间 (23:59:59)
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    // MARK: - 相对时间
    
    /// 相对时间描述（刚刚、5分钟前、昨天等）
    var relativeString: String {
        let now = Date()
        let seconds = Int(now.timeIntervalSince(self))
        
        if seconds < 60 {
            return "刚刚"
        } else if seconds < 3600 {
            return "\(seconds / 60)分钟前"
        } else if seconds < 86400 {
            return "\(seconds / 3600)小时前"
        } else if isYesterday {
            return "昨天 \(shortTimeString)"
        } else if isThisYear {
            return string(format: "MM-dd HH:mm")
        } else {
            return string(format: "yyyy-MM-dd")
        }
    }
}

// MARK: - 字符串转日期

public extension String {
    
    /// 转换为日期
    func toDate(format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.date(from: self)
    }
}
