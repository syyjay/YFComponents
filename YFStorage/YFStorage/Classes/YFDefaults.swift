//
//  YFDefaults.swift
//  YFStorage
//
//  UserDefaults 类型安全封装
//

import Foundation

/// UserDefaults 封装
public enum YFDefaults {
    
    private static let defaults = UserDefaults.standard
    
    // MARK: - 基础类型
    
    /// 存储值
    public static func set(_ value: Any?, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    /// 获取值
    public static func get<T>(_ key: String) -> T? {
        defaults.object(forKey: key) as? T
    }
    
    /// 获取值（带默认值）
    public static func get<T>(_ key: String, default defaultValue: T) -> T {
        (defaults.object(forKey: key) as? T) ?? defaultValue
    }
    
    /// 删除值
    public static func remove(_ key: String) {
        defaults.removeObject(forKey: key)
    }
    
    /// 是否存在
    public static func contains(_ key: String) -> Bool {
        defaults.object(forKey: key) != nil
    }
    
    // MARK: - 便捷方法
    
    public static func string(_ key: String) -> String? {
        defaults.string(forKey: key)
    }
    
    public static func int(_ key: String) -> Int {
        defaults.integer(forKey: key)
    }
    
    public static func double(_ key: String) -> Double {
        defaults.double(forKey: key)
    }
    
    public static func bool(_ key: String) -> Bool {
        defaults.bool(forKey: key)
    }
    
    public static func data(_ key: String) -> Data? {
        defaults.data(forKey: key)
    }
    
    public static func array(_ key: String) -> [Any]? {
        defaults.array(forKey: key)
    }
    
    public static func dictionary(_ key: String) -> [String: Any]? {
        defaults.dictionary(forKey: key)
    }
    
    // MARK: - Codable 对象
    
    /// 存储 Codable 对象
    public static func set<T: Encodable>(_ object: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(object) {
            defaults.set(data, forKey: key)
        }
    }
    
    /// 获取 Codable 对象
    public static func model<T: Decodable>(_ key: String, type: T.Type = T.self) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - 批量操作
    
    /// 清除所有（当前 Bundle）
    public static func removeAll() {
        guard let bundleId = Bundle.main.bundleIdentifier else { return }
        defaults.removePersistentDomain(forName: bundleId)
    }
}

// MARK: - 属性包装器

/// UserDefaults 属性包装器
@propertyWrapper
public struct YFDefault<T> {
    
    let key: String
    let defaultValue: T
    
    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get { YFDefaults.get(key, default: defaultValue) }
        set { YFDefaults.set(newValue, forKey: key) }
    }
}

/// 可选值属性包装器
@propertyWrapper
public struct YFDefaultOptional<T> {
    
    let key: String
    
    public init(_ key: String) {
        self.key = key
    }
    
    public var wrappedValue: T? {
        get { YFDefaults.get(key) }
        set { YFDefaults.set(newValue, forKey: key) }
    }
}
