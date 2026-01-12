//
//  YFJSBridge.swift
//  YFWebView
//
//  JS 桥接
//

import Foundation
import WebKit
import YFLogger

// MARK: - JS 处理器协议

/// JS 消息处理器协议
public protocol YFJSHandler: AnyObject {
    /// 处理器名称（用于 JS 调用）
    var handlerName: String { get }
    
    /// 处理 JS 消息
    /// - Parameters:
    ///   - message: JS 传递的消息体
    ///   - callback: 回调函数，用于返回结果给 JS
    func handle(message: Any, callback: @escaping (Any?) -> Void)
}

// MARK: - JS 桥接器

/// JS 桥接管理器
public class YFJSBridge: NSObject {
    
    /// 桥接名称（JS 中使用的对象名）
    public static let bridgeName = "YFBridge"
    
    /// 注册的处理器
    private var handlers: [String: YFJSHandler] = [:]
    
    /// 闭包处理器
    private var closureHandlers: [String: (Any, @escaping (Any?) -> Void) -> Void] = [:]
    
    /// WebView 引用
    private weak var webView: WKWebView?
    
    /// 回调计数器
    private var callbackId: Int = 0
    
    /// 待处理的回调
    private var pendingCallbacks: [String: (Any?) -> Void] = [:]
    
    // MARK: - Init
    
    public override init() {
        super.init()
    }
    
    // MARK: - 配置
    
    /// 配置 WebView
    public func configure(with webView: WKWebView) {
        self.webView = webView
        
        // 注入桥接脚本
        injectBridgeScript()
    }
    
    /// 配置 WKUserContentController
    public func configure(contentController: WKUserContentController) {
        // 添加消息处理器
        contentController.add(LeakAvoider(delegate: self), name: YFJSBridge.bridgeName)
        
        // 注入桥接脚本
        let script = WKUserScript(
            source: bridgeScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        contentController.addUserScript(script)
    }
    
    // MARK: - 注册处理器
    
    /// 注册处理器对象
    public func register(handler: YFJSHandler) {
        handlers[handler.handlerName] = handler
        logD("注册 JS 处理器: \(handler.handlerName)")
    }
    
    /// 注册闭包处理器
    public func register(name: String, handler: @escaping (Any, @escaping (Any?) -> Void) -> Void) {
        closureHandlers[name] = handler
        logD("注册 JS 处理器: \(name)")
    }
    
    /// 移除处理器
    public func removeHandler(name: String) {
        handlers.removeValue(forKey: name)
        closureHandlers.removeValue(forKey: name)
    }
    
    /// 移除所有处理器
    public func removeAllHandlers() {
        handlers.removeAll()
        closureHandlers.removeAll()
    }
    
    // MARK: - 调用 JS
    
    /// 调用 JS 方法
    /// - Parameters:
    ///   - method: 方法名
    ///   - params: 参数（可选）
    ///   - completion: 完成回调
    public func callJS(
        method: String,
        params: Any? = nil,
        completion: ((Result<Any?, Error>) -> Void)? = nil
    ) {
        var script: String
        
        if let params = params {
            if let jsonData = try? JSONSerialization.data(withJSONObject: params),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                script = "\(method)(\(jsonString))"
            } else if let stringParam = params as? String {
                script = "\(method)('\(stringParam)')"
            } else {
                script = "\(method)(\(params))"
            }
        } else {
            script = "\(method)()"
        }
        
        evaluateJavaScript(script, completion: completion)
    }
    
    /// 执行 JavaScript 代码
    public func evaluateJavaScript(
        _ script: String,
        completion: ((Result<Any?, Error>) -> Void)? = nil
    ) {
        guard let webView = webView else {
            completion?(.failure(YFWebError.webViewNotFound))
            return
        }
        
        logD("执行 JS: \(script.prefix(100))...")
        
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                logE("JS 执行失败: \(error.localizedDescription)")
                completion?(.failure(error))
            } else {
                completion?(.success(result))
            }
        }
    }
    
    /// 调用 JS 并等待回调
    public func callJSWithCallback(
        method: String,
        params: Any? = nil,
        completion: @escaping (Any?) -> Void
    ) {
        callbackId += 1
        let cbId = "cb_\(callbackId)"
        pendingCallbacks[cbId] = completion
        
        var script: String
        if let params = params,
           let jsonData = try? JSONSerialization.data(withJSONObject: params),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            script = "\(method)(\(jsonString), '\(cbId)')"
        } else {
            script = "\(method)(null, '\(cbId)')"
        }
        
        evaluateJavaScript(script)
    }
    
    // MARK: - 私有方法
    
    private func injectBridgeScript() {
        evaluateJavaScript(bridgeScript)
    }
    
    /// 桥接脚本
    private var bridgeScript: String {
        return """
        (function() {
            if (window.\(YFJSBridge.bridgeName)) return;
            
            window.\(YFJSBridge.bridgeName) = {
                // 调用原生方法
                call: function(handlerName, params, callback) {
                    var message = {
                        handlerName: handlerName,
                        params: params || {}
                    };
                    
                    if (callback) {
                        var callbackId = 'cb_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
                        message.callbackId = callbackId;
                        this._callbacks[callbackId] = callback;
                    }
                    
                    window.webkit.messageHandlers.\(YFJSBridge.bridgeName).postMessage(message);
                },
                
                // 回调存储
                _callbacks: {},
                
                // 原生调用回调
                _handleCallback: function(callbackId, result) {
                    var callback = this._callbacks[callbackId];
                    if (callback) {
                        callback(result);
                        delete this._callbacks[callbackId];
                    }
                }
            };
            
            // 通知原生桥接已就绪
            window.dispatchEvent(new Event('YFBridgeReady'));
        })();
        """
    }
}

// MARK: - WKScriptMessageHandler

extension YFJSBridge: WKScriptMessageHandler {
    
    public func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == YFJSBridge.bridgeName else { return }
        guard let body = message.body as? [String: Any] else { return }
        guard let handlerName = body["handlerName"] as? String else { return }
        
        let params = body["params"] ?? [:]
        let callbackId = body["callbackId"] as? String
        
        logD("收到 JS 消息: \(handlerName)")
        
        // 回调函数
        let callback: (Any?) -> Void = { [weak self] result in
            guard let callbackId = callbackId else { return }
            self?.sendCallback(callbackId: callbackId, result: result)
        }
        
        // 查找处理器
        if let handler = handlers[handlerName] {
            handler.handle(message: params, callback: callback)
        } else if let closureHandler = closureHandlers[handlerName] {
            closureHandler(params, callback)
        } else {
            logW("未找到 JS 处理器: \(handlerName)")
        }
    }
    
    private func sendCallback(callbackId: String, result: Any?) {
        var script: String
        
        if let result = result {
            if let jsonData = try? JSONSerialization.data(withJSONObject: result),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                script = "\(YFJSBridge.bridgeName)._handleCallback('\(callbackId)', \(jsonString))"
            } else if let stringResult = result as? String {
                script = "\(YFJSBridge.bridgeName)._handleCallback('\(callbackId)', '\(stringResult)')"
            } else {
                script = "\(YFJSBridge.bridgeName)._handleCallback('\(callbackId)', \(result))"
            }
        } else {
            script = "\(YFJSBridge.bridgeName)._handleCallback('\(callbackId)', null)"
        }
        
        evaluateJavaScript(script)
    }
}

// MARK: - 防止循环引用

private class LeakAvoider: NSObject, WKScriptMessageHandler {
    
    weak var delegate: WKScriptMessageHandler?
    
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

// MARK: - 错误类型

public enum YFWebError: Error, LocalizedError {
    case webViewNotFound
    case loadFailed(Error?)
    case invalidURL
    case timeout
    case jsBridgeError(String)
    
    public var errorDescription: String? {
        switch self {
        case .webViewNotFound:
            return "WebView 未找到"
        case .loadFailed(let error):
            return error?.localizedDescription ?? "加载失败"
        case .invalidURL:
            return "无效的 URL"
        case .timeout:
            return "请求超时"
        case .jsBridgeError(let message):
            return "JS 桥接错误: \(message)"
        }
    }
}
