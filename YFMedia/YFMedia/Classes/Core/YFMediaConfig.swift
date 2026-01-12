//
//  YFMediaConfig.swift
//  YFMedia
//
//  媒体选择配置
//

import UIKit
import Photos

// MARK: - 媒体来源

public enum YFMediaSource {
    /// 相册
    case photoLibrary
    /// 相机
    case camera
}

// MARK: - 媒体类型

public enum YFMediaType {
    /// 仅图片
    case image
    /// 仅视频
    case video
    /// 图片和视频
    case all
}

// MARK: - 裁剪比例

public enum YFCropRatio {
    /// 自由裁剪
    case free
    /// 正方形 1:1
    case square
    /// 自定义比例 (宽:高)
    case ratio(CGFloat)
    
    /// 获取比例值
    var value: CGFloat? {
        switch self {
        case .free: return nil
        case .square: return 1.0
        case .ratio(let r): return r
        }
    }
}

// MARK: - 压缩质量

public enum YFCompressionQuality {
    /// 不压缩
    case none
    /// 低质量 (0.3)
    case low
    /// 中等质量 (0.5)
    case medium
    /// 高质量 (0.8)
    case high
    /// 自定义 (0.0 - 1.0)
    case custom(CGFloat)
    
    /// 获取压缩值
    var value: CGFloat {
        switch self {
        case .none: return 1.0
        case .low: return 0.3
        case .medium: return 0.5
        case .high: return 0.8
        case .custom(let q): return max(0, min(1, q))
        }
    }
}

// MARK: - 相机设备

public enum YFCameraDevice {
    /// 前置摄像头
    case front
    /// 后置摄像头
    case rear
}

// MARK: - 闪光灯模式

public enum YFFlashMode {
    case auto
    case on
    case off
}

// MARK: - 媒体配置

public struct YFMediaConfig {
    
    // MARK: - 来源
    
    /// 媒体来源
    public var source: YFMediaSource = .photoLibrary
    
    // MARK: - 类型
    
    /// 媒体类型
    public var mediaType: YFMediaType = .image
    
    // MARK: - 选择限制
    
    /// 最大选择数量（相册模式有效）
    public var maxCount: Int = 1
    
    /// 视频最大时长（秒）
    public var maxVideoDuration: TimeInterval = 60
    
    // MARK: - 裁剪
    
    /// 是否允许裁剪（仅单选图片有效）
    public var allowsCrop: Bool = false
    
    /// 裁剪比例
    public var cropRatio: YFCropRatio = .free
    
    // MARK: - 压缩
    
    /// 压缩质量
    public var compression: YFCompressionQuality = .medium
    
    /// 最大宽度（0 表示不限制）
    public var maxWidth: CGFloat = 0
    
    /// 最大文件大小 KB（0 表示不限制）
    public var maxFileSizeKB: Int = 0
    
    // MARK: - 相机
    
    /// 相机设备
    public var cameraDevice: YFCameraDevice = .rear
    
    /// 闪光灯模式
    public var flashMode: YFFlashMode = .auto
    
    // MARK: - 初始化
    
    public init() {}
    
    /// 图片选择配置
    public static func imagePickerConfig(maxCount: Int = 1) -> YFMediaConfig {
        var config = YFMediaConfig()
        config.source = .photoLibrary
        config.mediaType = .image
        config.maxCount = maxCount
        return config
    }
    
    /// 拍照配置
    public static func cameraConfig() -> YFMediaConfig {
        var config = YFMediaConfig()
        config.source = .camera
        config.mediaType = .image
        return config
    }
    
    /// 视频选择配置
    public static func videoPickerConfig(maxDuration: TimeInterval = 60) -> YFMediaConfig {
        var config = YFMediaConfig()
        config.source = .photoLibrary
        config.mediaType = .video
        config.maxVideoDuration = maxDuration
        return config
    }
    
    /// 视频录制配置
    public static func videoRecordConfig(maxDuration: TimeInterval = 60) -> YFMediaConfig {
        var config = YFMediaConfig()
        config.source = .camera
        config.mediaType = .video
        config.maxVideoDuration = maxDuration
        return config
    }
}
