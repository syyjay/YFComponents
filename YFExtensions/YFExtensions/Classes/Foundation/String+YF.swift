//
//  String+YF.swift
//  YFExtensions
//
//  String 扩展
//

import Foundation
import CommonCrypto

public extension String {
    
    // MARK: - 校验
    
    /// 是否为空（去除空白字符后）
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// 是否是有效邮箱
    var isValidEmail: Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return range(of: pattern, options: .regularExpression) != nil
    }
    
    /// 是否是有效手机号（中国大陆）
    var isValidPhone: Bool {
        let pattern = "^1[3-9]\\d{9}$"
        return range(of: pattern, options: .regularExpression) != nil
    }
    
    /// 是否是有效 URL
    var isValidURL: Bool {
        URL(string: self) != nil
    }
    
    /// 是否是纯数字
    var isNumeric: Bool {
        !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    /// 是否包含中文
    var containsChinese: Bool {
        range(of: "\\p{Han}", options: .regularExpression) != nil
    }
    
    // MARK: - 转换
    
    /// 转 Int
    var toInt: Int? { Int(self) }
    
    /// 转 Double
    var toDouble: Double? { Double(self) }
    
    /// 转 URL
    var toURL: URL? { URL(string: self) }
    
    /// 转 Data (UTF8)
    var toData: Data? { data(using: .utf8) }
    
    /// 去除首尾空白
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// URL 编码
    var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    /// URL 解码
    var urlDecoded: String? {
        removingPercentEncoding
    }
    
    /// Base64 编码
    var base64Encoded: String? {
        data(using: .utf8)?.base64EncodedString()
    }
    
    /// Base64 解码
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - 加密
    
    /// MD5
    var md5: String {
        guard let data = data(using: .utf8) else { return self }
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ = data.withUnsafeBytes {
            CC_MD5($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    /// SHA256
    var sha256: String {
        guard let data = data(using: .utf8) else { return self }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes {
            CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - 截取
    
    /// 安全下标
    subscript(safe index: Int) -> Character? {
        guard index >= 0 && index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }
    
    /// 安全子串
    subscript(safe range: Range<Int>) -> String? {
        guard range.lowerBound >= 0, range.upperBound <= count else { return nil }
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start..<end])
    }
    
    /// 前 N 个字符
    func first(_ n: Int) -> String {
        guard n > 0 else { return "" }
        return String(self.prefix(min(n, count)))
    }
    
    /// 后 N 个字符
    func last(_ n: Int) -> String {
        guard n > 0 else { return "" }
        return String(self.suffix(min(n, count)))
    }
    
    // MARK: - 格式化
    
    /// 手机号脱敏 (138****8888)
    var maskedPhone: String {
        guard count == 11 else { return self }
        return first(3) + "****" + last(4)
    }
    
    /// 邮箱脱敏 (t***@example.com)
    var maskedEmail: String {
        guard let atIndex = firstIndex(of: "@") else { return self }
        let name = String(self[startIndex..<atIndex])
        let domain = String(self[atIndex...])
        if name.count <= 1 {
            return name + "***" + domain
        }
        return name.first(1) + "***" + domain
    }
}

// MARK: - 正则

public extension String {
    
    /// 正则匹配
    func matches(pattern: String) -> Bool {
        range(of: pattern, options: .regularExpression) != nil
    }
    
    /// 正则替换
    func replacing(pattern: String, with replacement: String) -> String {
        replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
    }
    
    /// 提取正则匹配结果
    func extract(pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(startIndex..., in: self)
        return regex.matches(in: self, range: range).compactMap {
            guard let r = Range($0.range, in: self) else { return nil }
            return String(self[r])
        }
    }
}
