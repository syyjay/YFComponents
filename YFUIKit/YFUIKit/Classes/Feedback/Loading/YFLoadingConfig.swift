//
//  YFLoadingConfig.swift
//  YFUIKit
//
//  Loading 配置项
//

import UIKit

/// 遮罩类型
public enum YFLoadingMaskType {
    /// 无遮罩（可交互）
    case none
    /// 透明遮罩（不可交互）
    case clear
    /// 黑色半透明遮罩
    case black
    /// 自定义颜色遮罩
    case custom(UIColor)
    
    var color: UIColor {
        switch self {
        case .none, .clear:
            return .clear
        case .black:
            return UIColor.black.withAlphaComponent(0.3)
        case .custom(let color):
            return color
        }
    }
    
    var isUserInteractionEnabled: Bool {
        switch self {
        case .none:
            return true
        default:
            return false
        }
    }
}

/// Loading 状态类型
public enum YFLoadingStatus {
    /// 加载中
    case loading
    /// 成功
    case success
    /// 失败
    case error
    /// 警告
    case warning
    /// 进度
    case progress(Float)
    
    var icon: UIImage? {
        switch self {
        case .loading, .progress:
            return nil
        case .success:
            return UIImage(systemName: "checkmark")
        case .error:
            return UIImage(systemName: "xmark")
        case .warning:
            return UIImage(systemName: "exclamationmark.triangle")
        }
    }
    
    var iconColor: UIColor {
        switch self {
        case .loading, .progress:
            return .themed(\.primary)
        case .success:
            return .themed(\.success)
        case .error:
            return .themed(\.error)
        case .warning:
            return .themed(\.warning)
        }
    }
}

/// Loading 配置
public struct YFLoadingConfig {
    /// 文字
    public var text: String?
    /// 遮罩类型
    public var maskType: YFLoadingMaskType = .clear
    /// 状态
    public var status: YFLoadingStatus = .loading
    /// 自动隐藏延时（nil 表示不自动隐藏）
    public var autoDismissDelay: TimeInterval?
    /// 容器圆角
    public var cornerRadius: CGFloat = 12
    /// 容器最小尺寸
    public var minimumSize: CGSize = CGSize(width: 100, height: 100)
    /// 动画尺寸
    public var indicatorSize: CGFloat = 40
    
    public init() {}
}
