//
//  YFKeychain.swift
//  YFStorage
//
//  Keychain 敏感数据存储
//

import Foundation
import Security

/// Keychain 封装
public enum YFKeychain {
    
    /// 默认 Service
    public static var defaultService: String = Bundle.main.bundleIdentifier ?? "YFKeychain"
    
    // MARK: - String
    
    /// 存储字符串
    @discardableResult
    public static func set(_ value: String, forKey key: String, service: String? = nil) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return set(data, forKey: key, service: service)
    }
    
    /// 获取字符串
    public static func get(_ key: String, service: String? = nil) -> String? {
        guard let data = getData(key, service: service) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Data
    
    /// 存储 Data
    @discardableResult
    public static func set(_ data: Data, forKey key: String, service: String? = nil) -> Bool {
        let svc = service ?? defaultService
        
        // 先删除旧值
        delete(key, service: service)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: svc,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// 获取 Data
    public static func getData(_ key: String, service: String? = nil) -> Data? {
        let svc = service ?? defaultService
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: svc,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }
    
    // MARK: - Codable
    
    /// 存储 Codable 对象
    @discardableResult
    public static func set<T: Encodable>(_ object: T, forKey key: String, service: String? = nil) -> Bool {
        guard let data = try? JSONEncoder().encode(object) else { return false }
        return set(data, forKey: key, service: service)
    }
    
    /// 获取 Codable 对象
    public static func model<T: Decodable>(_ key: String, type: T.Type = T.self, service: String? = nil) -> T? {
        guard let data = getData(key, service: service) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - 删除
    
    /// 删除指定 Key
    @discardableResult
    public static func delete(_ key: String, service: String? = nil) -> Bool {
        let svc = service ?? defaultService
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: svc,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    /// 清除所有（当前 Service）
    @discardableResult
    public static func removeAll(service: String? = nil) -> Bool {
        let svc = service ?? defaultService
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: svc
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - 检查
    
    /// 是否存在
    public static func contains(_ key: String, service: String? = nil) -> Bool {
        getData(key, service: service) != nil
    }
}
