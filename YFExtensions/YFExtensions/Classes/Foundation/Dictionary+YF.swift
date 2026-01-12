//
//  Dictionary+YF.swift
//  YFExtensions
//
//  Dictionary 扩展
//

import Foundation

public extension Dictionary {
    
    // MARK: - 转换
    
    /// 转 JSON 字符串
    var jsonString: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self),
              let str = String(data: data, encoding: .utf8) else { return nil }
        return str
    }
    
    /// 转 JSON 字符串（格式化）
    var prettyJsonString: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
              let str = String(data: data, encoding: .utf8) else { return nil }
        return str
    }
    
    /// 转 Data
    var jsonData: Data? {
        try? JSONSerialization.data(withJSONObject: self)
    }
    
    // MARK: - 合并
    
    /// 合并另一个字典
    mutating func merge(_ other: [Key: Value]) {
        for (key, value) in other {
            self[key] = value
        }
    }
    
    /// 合并后返回新字典
    func merging(_ other: [Key: Value]) -> [Key: Value] {
        var result = self
        result.merge(other)
        return result
    }
}

public extension Dictionary where Key == String {
    
    // MARK: - 类型安全获取
    
    /// 获取 String
    func string(_ key: String) -> String? {
        self[key] as? String
    }
    
    /// 获取 Int
    func int(_ key: String) -> Int? {
        if let value = self[key] as? Int { return value }
        if let value = self[key] as? String { return Int(value) }
        return nil
    }
    
    /// 获取 Double
    func double(_ key: String) -> Double? {
        if let value = self[key] as? Double { return value }
        if let value = self[key] as? String { return Double(value) }
        return nil
    }
    
    /// 获取 Bool
    func bool(_ key: String) -> Bool? {
        if let value = self[key] as? Bool { return value }
        if let value = self[key] as? Int { return value != 0 }
        if let value = self[key] as? String { return value == "true" || value == "1" }
        return nil
    }
    
    /// 获取数组
    func array<T>(_ key: String) -> [T]? {
        self[key] as? [T]
    }
    
    /// 获取字典
    func dictionary(_ key: String) -> [String: Any]? {
        self[key] as? [String: Any]
    }
}

// MARK: - JSON 字符串转字典

public extension String {
    
    /// 转字典
    var toDictionary: [String: Any]? {
        guard let data = data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return dict
    }
    
    /// 转数组
    var toArray: [Any]? {
        guard let data = data(using: .utf8),
              let arr = try? JSONSerialization.jsonObject(with: data) as? [Any] else { return nil }
        return arr
    }
}
