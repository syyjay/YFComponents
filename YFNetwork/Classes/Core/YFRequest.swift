//
//  YFRequest.swift
//  YFNetwork
//
//  链式请求构建器
//

import Foundation
import Moya

/// 链式请求构建器
public final class YFRequest {
    
    private var urlString: String
    private var httpMethod: Moya.Method = .get
    private var params: [String: Any]?
    private var encoding: ParameterEncoding?
    private var customHeaders: [String: String] = [:]
    
    private static var provider: MoyaProvider<DynamicTarget>?
    
    public init(_ url: String) {
        self.urlString = url
    }
    
    // MARK: - 链式配置
    
    /// 设置请求方法
    @discardableResult
    public func method(_ m: Moya.Method) -> Self {
        httpMethod = m
        return self
    }
    
    /// 设置参数
    @discardableResult
    public func params(_ p: [String: Any]) -> Self {
        params = p
        return self
    }
    
    /// URL 编码
    @discardableResult
    public func urlEncoding() -> Self {
        encoding = URLEncoding.default
        return self
    }
    
    /// JSON 编码
    @discardableResult
    public func jsonEncoding() -> Self {
        encoding = JSONEncoding.default
        return self
    }
    
    /// 设置多个 Headers
    @discardableResult
    public func headers(_ h: [String: String]) -> Self {
        customHeaders.merge(h) { _, new in new }
        return self
    }
    
    /// 设置单个 Header
    @discardableResult
    public func header(_ key: String, _ value: String) -> Self {
        customHeaders[key] = value
        return self
    }
    
    // MARK: - 发起请求
    
    /// 请求原始数据
    @discardableResult
    public func response(_ completion: @escaping (Result<Data, YFNetworkError>) -> Void) -> Cancellable {
        let target = buildTarget()
        return getProvider().request(target) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let resp):
                    guard (200...299).contains(resp.statusCode) else {
                        completion(.failure(.statusCode(resp.statusCode, resp.data)))
                        return
                    }
                    completion(.success(resp.data))
                case .failure(let e):
                    completion(.failure(.moyaError(e)))
                }
            }
        }
    }
    
    /// 请求 JSON
    @discardableResult
    public func responseJSON(_ completion: @escaping (Result<Any, YFNetworkError>) -> Void) -> Cancellable {
        response { result in
            switch result {
            case .success(let data):
                if let json = try? JSONSerialization.jsonObject(with: data) {
                    completion(.success(json))
                } else {
                    completion(.failure(.decodeFailed(NSError(domain: "", code: -1))))
                }
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }
    
    /// 请求并解析模型
    @discardableResult
    public func responseModel<T: Decodable>(_ type: T.Type, completion: @escaping (Result<T, YFNetworkError>) -> Void) -> Cancellable {
        response { result in
            switch result {
            case .success(let data):
                do {
                    let obj = try YFNetworkConfig.shared.decoder.decode(T.self, from: data)
                    completion(.success(obj))
                } catch {
                    completion(.failure(.decodeFailed(error)))
                }
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }
    
    /// 请求并解析数组
    @discardableResult
    public func responseArray<T: Decodable>(_ type: T.Type, completion: @escaping (Result<[T], YFNetworkError>) -> Void) -> Cancellable {
        responseModel([T].self, completion: completion)
    }
    
    // MARK: - Private
    
    private func buildTarget() -> DynamicTarget {
        var fullURL = urlString
        if !urlString.hasPrefix("http"), !YFNetworkConfig.shared.baseURL.isEmpty {
            fullURL = YFNetworkConfig.shared.baseURL + urlString
        }
        
        var allHeaders = YFNetworkConfig.shared.headers
        allHeaders.merge(customHeaders) { _, new in new }
        
        let enc = encoding ?? (httpMethod == .get ? URLEncoding.default : JSONEncoding.default)
        let task: Task = params != nil
            ? .requestParameters(parameters: params!, encoding: enc)
            : .requestPlain
        
        return DynamicTarget(
            baseURL: URL(string: fullURL)!,
            path: "",
            method: httpMethod,
            task: task,
            headers: allHeaders
        )
    }
    
    private func getProvider() -> MoyaProvider<DynamicTarget> {
        if let p = YFRequest.provider { return p }
        
        var plugins: [PluginType] = []
        if YFNetworkConfig.shared.enableLog {
            plugins.append(YFLogPlugin())
        }
        
        let p = MoyaProvider<DynamicTarget>(plugins: plugins)
        YFRequest.provider = p
        return p
    }
}

// MARK: - Async

@available(iOS 13.0, *)
public extension YFRequest {
    
    func response() async throws -> Data {
        try await withCheckedThrowingContinuation { c in
            response { c.resume(with: $0) }
        }
    }
    
    func responseModel<T: Decodable>(_ type: T.Type) async throws -> T {
        try await withCheckedThrowingContinuation { c in
            responseModel(type) { c.resume(with: $0) }
        }
    }
    
    func responseArray<T: Decodable>(_ type: T.Type) async throws -> [T] {
        try await withCheckedThrowingContinuation { c in
            responseArray(type) { c.resume(with: $0) }
        }
    }
}

// MARK: - 动态 Target

struct DynamicTarget: TargetType {
    let baseURL: URL
    let path: String
    let method: Moya.Method
    let task: Task
    let headers: [String: String]?
    var sampleData: Data { Data() }
}
