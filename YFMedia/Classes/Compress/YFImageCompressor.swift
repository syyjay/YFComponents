//
//  YFImageCompressor.swift
//  YFMedia
//
//  图片压缩工具
//

import UIKit
import YFLogger

public final class YFImageCompressor {
    
    // MARK: - 质量压缩
    
    /// 按质量压缩图片
    /// - Parameters:
    ///   - image: 原图
    ///   - quality: 压缩质量
    /// - Returns: 压缩后的图片
    public static func compress(_ image: UIImage, quality: YFCompressionQuality) -> UIImage {
        guard quality.value < 1.0 else { return image }
        
        guard let data = image.jpegData(compressionQuality: quality.value),
              let compressed = UIImage(data: data) else {
            return image
        }
        
        logD("图片压缩: \(image.size) -> \(compressed.size), 质量: \(quality.value)")
        return compressed
    }
    
    /// 压缩到指定大小以下
    /// - Parameters:
    ///   - image: 原图
    ///   - maxSizeKB: 最大文件大小（KB）
    /// - Returns: 压缩后的图片
    public static func compress(_ image: UIImage, maxSizeKB: Int) -> UIImage {
        guard maxSizeKB > 0 else { return image }
        
        let maxBytes = maxSizeKB * 1024
        var quality: CGFloat = 1.0
        var data = image.jpegData(compressionQuality: quality)
        
        // 二分法压缩
        var minQuality: CGFloat = 0.0
        var maxQuality: CGFloat = 1.0
        
        for _ in 0..<6 {
            if let currentData = data, currentData.count <= maxBytes {
                break
            }
            
            quality = (minQuality + maxQuality) / 2
            data = image.jpegData(compressionQuality: quality)
            
            if let currentData = data {
                if currentData.count > maxBytes {
                    maxQuality = quality
                } else {
                    minQuality = quality
                }
            }
        }
        
        guard let finalData = data, let compressed = UIImage(data: finalData) else {
            return image
        }
        
        logD("图片压缩到 \(maxSizeKB)KB: \(finalData.count / 1024)KB, 质量: \(quality)")
        return compressed
    }
    
    // MARK: - 尺寸压缩
    
    /// 按最大宽度压缩图片
    /// - Parameters:
    ///   - image: 原图
    ///   - maxWidth: 最大宽度
    /// - Returns: 压缩后的图片
    public static func compress(_ image: UIImage, maxWidth: CGFloat) -> UIImage {
        guard maxWidth > 0, image.size.width > maxWidth else { return image }
        
        let scale = maxWidth / image.size.width
        let newSize = CGSize(width: maxWidth, height: image.size.height * scale)
        
        return resize(image, to: newSize)
    }
    
    /// 按最大尺寸压缩图片
    /// - Parameters:
    ///   - image: 原图
    ///   - maxSize: 最大尺寸（宽或高）
    /// - Returns: 压缩后的图片
    public static func compress(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        guard maxSize > 0 else { return image }
        
        let maxDimension = max(image.size.width, image.size.height)
        guard maxDimension > maxSize else { return image }
        
        let scale = maxSize / maxDimension
        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        
        return resize(image, to: newSize)
    }
    
    // MARK: - 综合压缩
    
    /// 综合压缩（先尺寸后质量）
    /// - Parameters:
    ///   - image: 原图
    ///   - config: 压缩配置
    /// - Returns: 压缩后的图片
    public static func compress(_ image: UIImage, config: YFMediaConfig) -> UIImage {
        var result = image
        
        // 1. 尺寸压缩
        if config.maxWidth > 0 {
            result = compress(result, maxWidth: config.maxWidth)
        }
        
        // 2. 质量压缩
        if config.compression.value < 1.0 {
            result = compress(result, quality: config.compression)
        }
        
        // 3. 文件大小压缩
        if config.maxFileSizeKB > 0 {
            result = compress(result, maxSizeKB: config.maxFileSizeKB)
        }
        
        return result
    }
    
    // MARK: - 辅助方法
    
    /// 调整图片尺寸
    private static func resize(_ image: UIImage, to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        
        logD("图片缩放: \(image.size) -> \(size)")
        return resized
    }
    
    /// 获取图片数据大小
    public static func dataSize(of image: UIImage, quality: CGFloat = 1.0) -> Int {
        return image.jpegData(compressionQuality: quality)?.count ?? 0
    }
    
    /// 格式化文件大小
    public static func formatSize(_ bytes: Int) -> String {
        if bytes < 1024 {
            return "\(bytes) B"
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024)
        } else {
            return String(format: "%.2f MB", Double(bytes) / 1024 / 1024)
        }
    }
}
