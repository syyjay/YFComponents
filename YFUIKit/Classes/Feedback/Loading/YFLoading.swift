//
//  YFLoading.swift
//  YFUIKit
//
//  Loading/HUD 加载指示器
//

import UIKit

/// Loading 加载指示器
public final class YFLoading {
    
    // MARK: - Singleton
    
    private static let shared = YFLoading()
    private init() {}
    
    // MARK: - Properties
    
    private var loadingViews: [ObjectIdentifier: YFLoadingView] = [:]
    private var globalLoadingView: YFLoadingView?
    private var autoDismissWorkItem: DispatchWorkItem?
    
    // MARK: - Show Loading
    
    /// 显示加载中
    /// - Parameters:
    ///   - text: 文字（可选）
    ///   - maskType: 遮罩类型
    public static func show(_ text: String? = nil, maskType: YFLoadingMaskType = .clear) {
        var config = YFLoadingConfig()
        config.text = text
        config.maskType = maskType
        config.status = .loading
        shared.show(config: config, in: nil)
    }
    
    /// 在指定视图上显示加载中
    /// - Parameters:
    ///   - view: 目标视图
    ///   - text: 文字（可选）
    ///   - maskType: 遮罩类型
    public static func show(in view: UIView, text: String? = nil, maskType: YFLoadingMaskType = .clear) {
        var config = YFLoadingConfig()
        config.text = text
        config.maskType = maskType
        config.status = .loading
        shared.show(config: config, in: view)
    }
    
    // MARK: - Show Status
    
    /// 显示成功
    /// - Parameters:
    ///   - text: 文字
    ///   - duration: 显示时长
    public static func success(_ text: String? = "成功", duration: TimeInterval = 1.5) {
        var config = YFLoadingConfig()
        config.text = text
        config.status = .success
        config.autoDismissDelay = duration
        shared.show(config: config, in: nil)
    }
    
    /// 显示失败
    /// - Parameters:
    ///   - text: 文字
    ///   - duration: 显示时长
    public static func error(_ text: String? = "失败", duration: TimeInterval = 1.5) {
        var config = YFLoadingConfig()
        config.text = text
        config.status = .error
        config.autoDismissDelay = duration
        shared.show(config: config, in: nil)
    }
    
    /// 显示警告
    /// - Parameters:
    ///   - text: 文字
    ///   - duration: 显示时长
    public static func warning(_ text: String? = "警告", duration: TimeInterval = 1.5) {
        var config = YFLoadingConfig()
        config.text = text
        config.status = .warning
        config.autoDismissDelay = duration
        shared.show(config: config, in: nil)
    }
    
    // MARK: - Progress
    
    /// 显示进度
    /// - Parameters:
    ///   - progress: 进度值 (0-1)
    ///   - text: 文字
    public static func showProgress(_ progress: Float, text: String? = nil) {
        var config = YFLoadingConfig()
        config.text = text
        config.status = .progress(progress)
        shared.show(config: config, in: nil)
    }
    
    /// 更新进度
    /// - Parameter progress: 进度值 (0-1)
    public static func updateProgress(_ progress: Float) {
        shared.globalLoadingView?.updateProgress(progress)
    }
    
    // MARK: - Hide
    
    /// 隐藏加载
    public static func hide() {
        shared.hide(from: nil)
    }
    
    /// 从指定视图隐藏加载
    /// - Parameter view: 目标视图
    public static func hide(from view: UIView) {
        shared.hide(from: view)
    }
    
    /// 隐藏所有加载
    public static func hideAll() {
        shared.hideAll()
    }
    
    // MARK: - Private Methods
    
    private func show(config: YFLoadingConfig, in view: UIView?) {
        DispatchQueue.main.async {
            self.autoDismissWorkItem?.cancel()
            
            if let targetView = view {
                // 在指定视图上显示
                self.showInView(targetView, config: config)
            } else {
                // 全局显示
                self.showGlobal(config: config)
            }
            
            // 自动隐藏
            if let delay = config.autoDismissDelay {
                let workItem = DispatchWorkItem { [weak self] in
                    if view != nil {
                        self?.hide(from: view)
                    } else {
                        self?.hide(from: nil)
                    }
                }
                self.autoDismissWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
            }
        }
    }
    
    private func showGlobal(config: YFLoadingConfig) {
        guard let window = YFApp.keyWindow else { return }
        
        if let existingView = globalLoadingView {
            // 更新现有视图
            existingView.configure(with: config)
        } else {
            // 创建新视图
            let loadingView = YFLoadingView(config: config)
            window.addSubview(loadingView)
            loadingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            loadingView.showAnimation()
            globalLoadingView = loadingView
        }
    }
    
    private func showInView(_ view: UIView, config: YFLoadingConfig) {
        let key = ObjectIdentifier(view)
        
        if let existingView = loadingViews[key] {
            // 更新现有视图
            existingView.configure(with: config)
        } else {
            // 创建新视图
            let loadingView = YFLoadingView(config: config)
            view.addSubview(loadingView)
            loadingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            loadingView.showAnimation()
            loadingViews[key] = loadingView
        }
    }
    
    private func hide(from view: UIView?) {
        DispatchQueue.main.async {
            self.autoDismissWorkItem?.cancel()
            self.autoDismissWorkItem = nil
            
            if let targetView = view {
                // 隐藏指定视图上的 Loading
                let key = ObjectIdentifier(targetView)
                if let loadingView = self.loadingViews[key] {
                    loadingView.hideAnimation {
                        loadingView.removeFromSuperview()
                    }
                    self.loadingViews.removeValue(forKey: key)
                }
            } else {
                // 隐藏全局 Loading
                if let loadingView = self.globalLoadingView {
                    loadingView.hideAnimation {
                        loadingView.removeFromSuperview()
                    }
                    self.globalLoadingView = nil
                }
            }
        }
    }
    
    private func hideAll() {
        DispatchQueue.main.async {
            self.autoDismissWorkItem?.cancel()
            self.autoDismissWorkItem = nil
            
            // 隐藏全局
            self.globalLoadingView?.hideAnimation {
                self.globalLoadingView?.removeFromSuperview()
            }
            self.globalLoadingView = nil
            
            // 隐藏所有视图上的
            for (_, loadingView) in self.loadingViews {
                loadingView.hideAnimation {
                    loadingView.removeFromSuperview()
                }
            }
            self.loadingViews.removeAll()
        }
    }
}

// MARK: - UIView Extension

public extension UIView {
    
    /// 显示加载
    func yf_showLoading(_ text: String? = nil) {
        YFLoading.show(in: self, text: text)
    }
    
    /// 隐藏加载
    func yf_hideLoading() {
        YFLoading.hide(from: self)
    }
}
