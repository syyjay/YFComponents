//
//  YFNetwork.swift
//  YFNetwork
//
//  网络请求入口（常用调用）
//

import Foundation
import Moya

/// 网络请求入口
public enum YFNetwork {
    
    // MARK: - 链式 API
    
    /// GET 请求
    public static func get(_ url: String) -> YFRequest {
        YFRequest(url).method(.get)
    }
    
    /// POST 请求
    public static func post(_ url: String) -> YFRequest {
        YFRequest(url).method(.post)
    }
    
    /// PUT 请求
    public static func put(_ url: String) -> YFRequest {
        YFRequest(url).method(.put)
    }
    
    /// DELETE 请求
    public static func delete(_ url: String) -> YFRequest {
        YFRequest(url).method(.delete)
    }
    
    /// PATCH 请求
    public static func patch(_ url: String) -> YFRequest {
        YFRequest(url).method(.patch)
    }
    
    /// 配置
    public static var config: YFNetworkConfig { .shared }
}

// MARK: - TargetType 支持

public extension YFNetwork {
    
    private static var providers: [String: Any] = [:]
    
    /// TargetType 请求（原始数据）
    @discardableResult
    static func request<T: TargetType>(
        _ target: T,
        completion: @escaping (Result<Data, YFNetworkError>) -> Void
    ) -> Cancellable {
        getProvider(for: T.self).request(target) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let r):
                    guard (200...299).contains(r.statusCode) else {
                        completion(.failure(.statusCode(r.statusCode, r.data)))
                        return
                    }
                    completion(.success(r.data))
                case .failure(let e):
                    completion(.failure(.moyaError(e)))
                }
            }
        }
    }
    
    /// TargetType 请求（泛型解析）
    @discardableResult
    static func request<T: TargetType, R: Decodable>(
        _ target: T,
        type: R.Type,
        completion: @escaping (Result<R, YFNetworkError>) -> Void
    ) -> Cancellable {
        request(target) { result in
            switch result {
            case .success(let data):
                do {
                    let obj = try config.decoder.decode(R.self, from: data)
                    completion(.success(obj))
                } catch {
                    completion(.failure(.decodeFailed(error)))
                }
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }
    
    private static func getProvider<T: TargetType>(for type: T.Type) -> MoyaProvider<T> {
        let key = String(describing: type)
        if let p = providers[key] as? MoyaProvider<T> { return p }
        
        var plugins: [PluginType] = []
        if config.enableLog { plugins.append(YFLogPlugin()) }
        
        let p = MoyaProvider<T>(plugins: plugins)
        providers[key] = p
        return p
    }
}

// MARK: - Async

@available(iOS 13.0, *)
public extension YFNetwork {
    
    static func request<T: TargetType>(_ target: T) async throws -> Data {
        try await withCheckedThrowingContinuation { c in
            request(target) { c.resume(with: $0) }
        }
    }
    
    static func request<T: TargetType, R: Decodable>(_ target: T, type: R.Type) async throws -> R {
        try await withCheckedThrowingContinuation { c in
            request(target, type: type) { c.resume(with: $0) }
        }
    }
}
