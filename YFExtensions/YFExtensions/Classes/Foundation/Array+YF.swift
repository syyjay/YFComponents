//
//  Array+YF.swift
//  YFExtensions
//
//  Array 扩展
//

import Foundation

public extension Array {
    
    // MARK: - 安全访问
    
    /// 安全下标访问
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
    
    /// 第二个元素
    var second: Element? { self[safe: 1] }
    
    /// 第三个元素
    var third: Element? { self[safe: 2] }
    
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
}

public extension Array where Element: Equatable {
    
    // MARK: - 去重
    
    /// 去重
    var unique: [Element] {
        var result: [Element] = []
        for element in self {
            if !result.contains(element) {
                result.append(element)
            }
        }
        return result
    }
    
    /// 移除指定元素
    mutating func remove(_ element: Element) {
        removeAll { $0 == element }
    }
    
    /// 移除指定元素（返回新数组）
    func removing(_ element: Element) -> [Element] {
        filter { $0 != element }
    }
}

public extension Array where Element: Hashable {
    
    /// 去重（保持顺序）
    var uniqueOrdered: [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

// MARK: - Optional 数组

public extension Optional where Wrapped: Collection {
    
    /// 是否为空或 nil
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}
