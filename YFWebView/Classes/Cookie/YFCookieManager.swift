//
//  YFCookieManager.swift
//  YFWebView
//
//  Cookie 管理
//

import Foundation
import WebKit
import YFLogger

/// Cookie 管理器
public class YFCookieManager {
    
    public static let shared = YFCookieManager()
    
    private init() {}
    
    // MARK: - 获取 Cookie
    
    /// 获取所有 Cookie
    public func getAllCookies(completion: @escaping ([HTTPCookie]) -> Void) {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            completion(cookies)
        }
    }
    
    /// 获取指定域名的 Cookie
    public func getCookies(for domain: String, completion: @escaping ([HTTPCookie]) -> Void) {
        getAllCookies { cookies in
            let filtered = cookies.filter { $0.domain.contains(domain) }
            completion(filtered)
        }
    }
    
    /// 获取指定名称的 Cookie
    public func getCookie(named name: String, for domain: String? = nil, completion: @escaping (HTTPCookie?) -> Void) {
        getAllCookies { cookies in
            let cookie = cookies.first { cookie in
                if cookie.name != name { return false }
                if let domain = domain, !cookie.domain.contains(domain) { return false }
                return true
            }
            completion(cookie)
        }
    }
    
    // MARK: - 设置 Cookie
    
    /// 设置 Cookie
    public func setCookie(_ cookie: HTTPCookie, completion: (() -> Void)? = nil) {
        WKWebsiteDataStore.default().httpCookieStore.setCookie(cookie) {
            logD("设置 Cookie: \(cookie.name)=\(cookie.value)")
            completion?()
        }
    }
    
    /// 设置 Cookie（便捷方法）
    public func setCookie(
        name: String,
        value: String,
        domain: String,
        path: String = "/",
        expiresDate: Date? = nil,
        isSecure: Bool = false,
        isHTTPOnly: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        var properties: [HTTPCookiePropertyKey: Any] = [
            .name: name,
            .value: value,
            .domain: domain,
            .path: path
        ]
        
        if let expiresDate = expiresDate {
            properties[.expires] = expiresDate
        }
        
        if isSecure {
            properties[.secure] = true
        }
        
        if let cookie = HTTPCookie(properties: properties) {
            setCookie(cookie, completion: completion)
        }
    }
    
    /// 批量设置 Cookie
    public func setCookies(_ cookies: [HTTPCookie], completion: (() -> Void)? = nil) {
        let group = DispatchGroup()
        
        for cookie in cookies {
            group.enter()
            setCookie(cookie) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion?()
        }
    }
    
    /// 从 Cookie 字符串设置（格式：name=value; name2=value2）
    public func setCookies(from cookieString: String, for domain: String, completion: (() -> Void)? = nil) {
        let pairs = cookieString.components(separatedBy: ";")
        var cookies: [HTTPCookie] = []
        
        for pair in pairs {
            let trimmed = pair.trimmingCharacters(in: .whitespaces)
            let parts = trimmed.components(separatedBy: "=")
            
            if parts.count >= 2 {
                let name = parts[0]
                let value = parts.dropFirst().joined(separator: "=")
                
                if let cookie = HTTPCookie(properties: [
                    .name: name,
                    .value: value,
                    .domain: domain,
                    .path: "/"
                ]) {
                    cookies.append(cookie)
                }
            }
        }
        
        setCookies(cookies, completion: completion)
    }
    
    // MARK: - 删除 Cookie
    
    /// 删除指定 Cookie
    public func deleteCookie(_ cookie: HTTPCookie, completion: (() -> Void)? = nil) {
        WKWebsiteDataStore.default().httpCookieStore.delete(cookie) {
            logD("删除 Cookie: \(cookie.name)")
            completion?()
        }
    }
    
    /// 删除指定名称的 Cookie
    public func deleteCookie(named name: String, for domain: String? = nil, completion: (() -> Void)? = nil) {
        getCookie(named: name, for: domain) { [weak self] cookie in
            if let cookie = cookie {
                self?.deleteCookie(cookie, completion: completion)
            } else {
                completion?()
            }
        }
    }
    
    /// 删除指定域名的所有 Cookie
    public func deleteCookies(for domain: String, completion: (() -> Void)? = nil) {
        getCookies(for: domain) { [weak self] cookies in
            let group = DispatchGroup()
            
            for cookie in cookies {
                group.enter()
                self?.deleteCookie(cookie) {
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                logD("删除域名 \(domain) 的所有 Cookie，共 \(cookies.count) 个")
                completion?()
            }
        }
    }
    
    /// 删除所有 Cookie
    public func deleteAllCookies(completion: (() -> Void)? = nil) {
        let dataStore = WKWebsiteDataStore.default()
        let types = Set([WKWebsiteDataTypeCookies])
        
        dataStore.fetchDataRecords(ofTypes: types) { records in
            dataStore.removeData(ofTypes: types, for: records) {
                logD("删除所有 Cookie")
                completion?()
            }
        }
    }
    
    // MARK: - 同步 Cookie
    
    /// 将 HTTPCookieStorage 中的 Cookie 同步到 WKWebView
    public func syncCookiesFromHTTPCookieStorage(for domain: String? = nil, completion: (() -> Void)? = nil) {
        guard let cookies = HTTPCookieStorage.shared.cookies else {
            completion?()
            return
        }
        
        let filtered: [HTTPCookie]
        if let domain = domain {
            filtered = cookies.filter { $0.domain.contains(domain) }
        } else {
            filtered = cookies
        }
        
        setCookies(filtered, completion: completion)
    }
    
    /// 生成 Cookie 注入的 JavaScript
    public func generateCookieScript(for cookies: [HTTPCookie]) -> String {
        var script = ""
        for cookie in cookies {
            var cookieString = "\(cookie.name)=\(cookie.value)"
            cookieString += "; path=\(cookie.path)"
            if let domain = cookie.domain.first == "." ? cookie.domain : ".\(cookie.domain)" as String? {
                cookieString += "; domain=\(domain)"
            }
            if cookie.isSecure {
                cookieString += "; secure"
            }
            script += "document.cookie = '\(cookieString)';\n"
        }
        return script
    }
}
