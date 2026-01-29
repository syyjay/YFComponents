//
//  UIColor+YF.swift
//  YFUIKit
//
//  UIColor 通用扩展（Hex 初始化、颜色转换、亮度调整等）
//

import UIKit

public extension UIColor {
    
    // MARK: - Hex 初始化
    
    /// 从 Hex 字符串创建颜色
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        
        if hexString.hasPrefix("0X") {
            hexString = String(hexString.dropFirst(2))
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let r, g, b: CGFloat
        switch hexString.count {
        case 3: // RGB (12-bit)
            r = CGFloat((rgbValue >> 8) & 0xF) / 15.0
            g = CGFloat((rgbValue >> 4) & 0xF) / 15.0
            b = CGFloat(rgbValue & 0xF) / 15.0
        case 6: // RGB (24-bit)
            r = CGFloat((rgbValue >> 16) & 0xFF) / 255.0
            g = CGFloat((rgbValue >> 8) & 0xFF) / 255.0
            b = CGFloat(rgbValue & 0xFF) / 255.0
        case 8: // ARGB (32-bit)
            r = CGFloat((rgbValue >> 16) & 0xFF) / 255.0
            g = CGFloat((rgbValue >> 8) & 0xFF) / 255.0
            b = CGFloat(rgbValue & 0xFF) / 255.0
        default:
            r = 0; g = 0; b = 0
        }
        
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    /// 从 Hex 值创建颜色
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    /// 从 RGB 创建颜色 (0-255)
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: a
        )
    }
    
    // MARK: - 转换
    
    /// 转 Hex 字符串
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    /// 获取 RGBA 分量
    var rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
    
    // MARK: - 亮度调整
    
    /// 变亮
    func lighter(by percentage: CGFloat = 0.2) -> UIColor {
        adjustBrightness(by: abs(percentage))
    }
    
    /// 变暗
    func darker(by percentage: CGFloat = 0.2) -> UIColor {
        adjustBrightness(by: -abs(percentage))
    }
    
    /// 调整亮度
    func adjustBrightness(by percentage: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: min(max(b + percentage, 0), 1), alpha: a)
    }
    
    /// 调整透明度
    func alpha(_ value: CGFloat) -> UIColor {
        withAlphaComponent(value)
    }
    
    // MARK: - 动态颜色
    
    /// 创建动态颜色（Light/Dark）
    static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }
    
    /// 创建动态颜色（Hex 字符串版本）
    static func dynamic(light: String, dark: String) -> UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        }
    }
    
    // MARK: - 随机
    
    /// 随机颜色
    static var random: UIColor {
        UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1
        )
    }
}
