//
//  YFMediaResult.swift
//  YFMedia
//
//  媒体选择结果
//

import UIKit
import Photos

// MARK: - 媒体错误

public enum YFMediaError: Error, LocalizedError {
    /// 用户取消
    case cancelled
    /// 无权限
    case noPermission(String)
    /// 相机不可用
    case cameraUnavailable
    /// 加载失败
    case loadFailed
    /// 裁剪失败
    case cropFailed
    /// 压缩失败
    case compressFailed
    /// 保存失败
    case saveFailed
    /// 未知错误
    case unknown(Error?)
    
    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "用户取消"
        case .noPermission(let type):
            return "无\(type)访问权限"
        case .cameraUnavailable:
            return "相机不可用"
        case .loadFailed:
            return "加载失败"
        case .cropFailed:
            return "裁剪失败"
        case .compressFailed:
            return "压缩失败"
        case .saveFailed:
            return "保存失败"
        case .unknown(let error):
            return error?.localizedDescription ?? "未知错误"
        }
    }
}

// MARK: - 图片结果

public struct YFImageResult {
    /// 图片
    public let image: UIImage
    
    /// 原始图片（未压缩/裁剪前）
    public let originalImage: UIImage?
    
    /// 图片数据
    public var imageData: Data? {
        return image.jpegData(compressionQuality: 1.0)
    }
    
    /// 文件大小（字节）
    public var fileSize: Int {
        return imageData?.count ?? 0
    }
    
    /// 图片尺寸
    public var size: CGSize {
        return image.size
    }
    
    public init(image: UIImage, originalImage: UIImage? = nil) {
        self.image = image
        self.originalImage = originalImage
    }
}

// MARK: - 视频结果

public struct YFVideoResult {
    /// 视频文件 URL
    public let videoURL: URL
    
    /// 视频时长（秒）
    public let duration: TimeInterval
    
    /// 缩略图
    public let thumbnail: UIImage?
    
    /// 文件大小（字节）
    public var fileSize: Int64 {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: videoURL.path) else {
            return 0
        }
        return attributes[.size] as? Int64 ?? 0
    }
    
    public init(videoURL: URL, duration: TimeInterval, thumbnail: UIImage?) {
        self.videoURL = videoURL
        self.duration = duration
        self.thumbnail = thumbnail
    }
}

// MARK: - 媒体结果

public enum YFMediaResult {
    /// 单张图片
    case image(YFImageResult)
    /// 多张图片
    case images([YFImageResult])
    /// 视频
    case video(YFVideoResult)
}
