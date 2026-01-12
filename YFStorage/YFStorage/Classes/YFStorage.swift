//
//  YFStorage.swift
//  YFStorage
//
//  数据存储入口
//

import Foundation

/// 数据存储入口
public enum YFStorage {
    
    /// UserDefaults（普通数据）
    public typealias Defaults = YFDefaults
    
    /// Keychain（敏感数据）
    public typealias Keychain = YFKeychain
    
    /// 磁盘缓存
    public typealias Cache = YFCache
}
