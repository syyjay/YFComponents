//
//  YFCache.swift
//  YFStorage
//
//  磁盘缓存
//

import Foundation

/// 过期时间
public enum YFCacheExpiry {
    case never
    case seconds(TimeInterval)
    case minutes(Int)
    case hours(Int)
    case days(Int)
    case date(Date)
    
    var date: Date {
        switch self {
        case .never:
            return Date.distantFuture
        case .seconds(let s):
            return Date().addingTimeInterval(s)
        case .minutes(let m):
            return Date().addingTimeInterval(TimeInterval(m * 60))
        case .hours(let h):
            return Date().addingTimeInterval(TimeInterval(h * 3600))
        case .days(let d):
            return Date().addingTimeInterval(TimeInterval(d * 86400))
        case .date(let d):
            return d
        }
    }
}

/// 磁盘缓存
public final class YFCache {
    
    /// 共享实例
    public static let shared = YFCache()
    
    /// 缓存目录
    private let cacheDirectory: URL
    
    /// 元数据文件
    private var metadata: [String: Date] = [:]
    private let metadataFile: URL
    
    private let queue = DispatchQueue(label: "com.yf.cache", attributes: .concurrent)
    
    public init(name: String = "YFCache") {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent(name)
        metadataFile = cacheDirectory.appendingPathComponent(".metadata")
        
        // 创建目录
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // 加载元数据
        loadMetadata()
    }
    
    // MARK: - Data
    
    /// 存储 Data
    public func set(_ data: Data, forKey key: String, expiry: YFCacheExpiry = .never) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let fileURL = self.fileURL(for: key)
            try? data.write(to: fileURL)
            self.metadata[key] = expiry.date
            self.saveMetadata()
        }
    }
    
    /// 获取 Data
    public func get(_ key: String) -> Data? {
        queue.sync {
            guard !isExpired(key) else {
                remove(key)
                return nil
            }
            let fileURL = fileURL(for: key)
            return try? Data(contentsOf: fileURL)
        }
    }
    
    // MARK: - Codable
    
    /// 存储 Codable 对象
    public func set<T: Encodable>(_ object: T, forKey key: String, expiry: YFCacheExpiry = .never) {
        guard let data = try? JSONEncoder().encode(object) else { return }
        set(data, forKey: key, expiry: expiry)
    }
    
    /// 获取 Codable 对象
    public func model<T: Decodable>(_ key: String, type: T.Type = T.self) -> T? {
        guard let data = get(key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - 删除
    
    /// 删除指定 Key
    public func remove(_ key: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let fileURL = self.fileURL(for: key)
            try? FileManager.default.removeItem(at: fileURL)
            self.metadata.removeValue(forKey: key)
            self.saveMetadata()
        }
    }
    
    /// 删除过期缓存
    public func removeExpired() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let now = Date()
            let expiredKeys = self.metadata.filter { $0.value < now }.keys
            for key in expiredKeys {
                let fileURL = self.fileURL(for: key)
                try? FileManager.default.removeItem(at: fileURL)
                self.metadata.removeValue(forKey: key)
            }
            self.saveMetadata()
        }
    }
    
    /// 清除所有缓存
    public func removeAll() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            try? FileManager.default.removeItem(at: self.cacheDirectory)
            try? FileManager.default.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
            self.metadata.removeAll()
        }
    }
    
    // MARK: - 检查
    
    /// 是否存在
    public func contains(_ key: String) -> Bool {
        queue.sync {
            guard !isExpired(key) else { return false }
            return FileManager.default.fileExists(atPath: fileURL(for: key).path)
        }
    }
    
    /// 缓存大小（字节）
    public var totalSize: Int {
        queue.sync {
            var size = 0
            let files = try? FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            files?.forEach { url in
                let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                size += fileSize
            }
            return size
        }
    }
    
    // MARK: - Private
    
    private func fileURL(for key: String) -> URL {
        let fileName = key.data(using: .utf8)?.base64EncodedString() ?? key
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    private func isExpired(_ key: String) -> Bool {
        guard let expiryDate = metadata[key] else { return false }
        return expiryDate < Date()
    }
    
    private func loadMetadata() {
        guard let data = try? Data(contentsOf: metadataFile),
              let dict = try? JSONDecoder().decode([String: Date].self, from: data) else { return }
        metadata = dict
    }
    
    private func saveMetadata() {
        guard let data = try? JSONEncoder().encode(metadata) else { return }
        try? data.write(to: metadataFile)
    }
}

// MARK: - 便捷静态方法

public extension YFCache {
    
    static func set(_ data: Data, forKey key: String, expiry: YFCacheExpiry = .never) {
        shared.set(data, forKey: key, expiry: expiry)
    }
    
    static func get(_ key: String) -> Data? {
        shared.get(key)
    }
    
    static func set<T: Encodable>(_ object: T, forKey key: String, expiry: YFCacheExpiry = .never) {
        shared.set(object, forKey: key, expiry: expiry)
    }
    
    static func model<T: Decodable>(_ key: String, type: T.Type = T.self) -> T? {
        shared.model(key, type: type)
    }
    
    static func remove(_ key: String) {
        shared.remove(key)
    }
    
    static func removeExpired() {
        shared.removeExpired()
    }
    
    static func removeAll() {
        shared.removeAll()
    }
    
    static func contains(_ key: String) -> Bool {
        shared.contains(key)
    }
}
