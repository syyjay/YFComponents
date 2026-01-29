//
//  UIImage+YF.swift
//  YFUIKit
//
//  UIImage 扩展
//

import UIKit

public extension UIImage {

    // MARK: - 创建

    /// 从颜色创建图片
    static func from(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        color.setFill()
        UIRectFill(rect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// 从渐变色创建图片
    static func gradient(
        colors: [UIColor],
        size: CGSize,
        startPoint: CGPoint = CGPoint(x: 0, y: 0),
        endPoint: CGPoint = CGPoint(x: 1, y: 1)
    ) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let cgColors = colors.map { $0.cgColor } as CFArray
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors, locations: nil) else { return nil }

        let start = CGPoint(x: startPoint.x * size.width, y: startPoint.y * size.height)
        let end = CGPoint(x: endPoint.x * size.width, y: endPoint.y * size.height)

        context.drawLinearGradient(gradient, start: start, end: end, options: [])

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // MARK: - 缩放

    /// 等比缩放到指定宽度
    func scaled(toWidth width: CGFloat) -> UIImage? {
        let scale = width / size.width
        let newHeight = size.height * scale
        return scaled(to: CGSize(width: width, height: newHeight))
    }

    /// 等比缩放到指定高度
    func scaled(toHeight height: CGFloat) -> UIImage? {
        let scale = height / size.height
        let newWidth = size.width * scale
        return scaled(to: CGSize(width: newWidth, height: height))
    }

    /// 缩放到指定尺寸
    func scaled(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // MARK: - 裁剪

    /// 裁剪为圆形
    func circled() -> UIImage? {
        let minSide = min(size.width, size.height)
        let squareSize = CGSize(width: minSide, height: minSide)

        UIGraphicsBeginImageContextWithOptions(squareSize, false, scale)
        defer { UIGraphicsEndImageContext() }

        let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: squareSize))
        path.addClip()

        let origin = CGPoint(
            x: (minSide - size.width) / 2,
            y: (minSide - size.height) / 2
        )
        draw(at: origin)

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// 裁剪为圆角
    func rounded(radius: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        let rect = CGRect(origin: .zero, size: size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        path.addClip()
        draw(in: rect)

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // MARK: - 颜色

    /// 修改图片颜色（适用于模板图片）
    func tinted(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        color.set()
        withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// 灰度图
    var grayscale: UIImage? {
        guard let cgImage = cgImage else { return nil }

        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(origin: .zero, size: size))

        guard let grayCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: grayCGImage, scale: scale, orientation: imageOrientation)
    }

    // MARK: - 压缩

    /// 压缩到指定大小（KB）
    func compressed(toKB maxKB: Int) -> Data? {
        var compression: CGFloat = 1.0
        var data = jpegData(compressionQuality: compression)

        while let d = data, d.count > maxKB * 1024, compression > 0.1 {
            compression -= 0.1
            data = jpegData(compressionQuality: compression)
        }

        return data
    }

    /// JPEG Data
    func jpegData(quality: CGFloat = 0.8) -> Data? {
        jpegData(compressionQuality: quality)
    }

    // MARK: - 信息

    /// 是否有透明通道
    var hasAlpha: Bool {
        guard let cgImage = cgImage else { return false }
        let alpha = cgImage.alphaInfo
        return alpha == .first || alpha == .last || alpha == .premultipliedFirst || alpha == .premultipliedLast
    }

    /// 图片大小（字节）
    var dataSize: Int? {
        pngData()?.count
    }
}
