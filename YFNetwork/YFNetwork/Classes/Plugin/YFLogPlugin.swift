//
//  YFLogPlugin.swift
//  YFNetwork
//
//  日志插件
//

import Foundation
import Moya
import YFLogger

/// 日志插件
struct YFLogPlugin: PluginType {
    
    func willSend(_ request: RequestType, target: TargetType) {
        guard YFNetworkConfig.shared.enableLog else { return }
        let method = request.request?.httpMethod ?? ""
        let url = request.request?.url?.absoluteString ?? ""
        logD("🚀 \(method) \(url)")
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        guard YFNetworkConfig.shared.enableLog else { return }
        switch result {
        case .success(let r):
            logD("📥 \(r.statusCode) | \(r.data.count) bytes")
        case .failure(let e):
            logE("❌ \(e.localizedDescription)")
        }
    }
}
