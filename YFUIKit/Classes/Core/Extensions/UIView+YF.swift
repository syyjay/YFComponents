//
//  UIView+YF.swift
//  YFUIKit
//
//  UIView 扩展
//

import UIKit

public extension UIView {

    // MARK: - 便捷属性

    var x: CGFloat {
        get { frame.origin.x }
        set { frame.origin.x = newValue }
    }

    var y: CGFloat {
        get { frame.origin.y }
        set { frame.origin.y = newValue }
    }

    var width: CGFloat {
        get { frame.size.width }
        set { frame.size.width = newValue }
    }

    var height: CGFloat {
        get { frame.size.height }
        set { frame.size.height = newValue }
    }

    var size: CGSize {
        get { frame.size }
        set { frame.size = newValue }
    }

    var origin: CGPoint {
        get { frame.origin }
        set { frame.origin = newValue }
    }

    var centerX: CGFloat {
        get { center.x }
        set { center.x = newValue }
    }

    var centerY: CGFloat {
        get { center.y }
        set { center.y = newValue }
    }

    var top: CGFloat {
        get { frame.origin.y }
        set { frame.origin.y = newValue }
    }

    var bottom: CGFloat {
        get { frame.origin.y + frame.size.height }
        set { frame.origin.y = newValue - frame.size.height }
    }

    var left: CGFloat {
        get { frame.origin.x }
        set { frame.origin.x = newValue }
    }

    var right: CGFloat {
        get { frame.origin.x + frame.size.width }
        set { frame.origin.x = newValue - frame.size.width }
    }

    // MARK: - 圆角

    /// 设置圆角
    @discardableResult
    func cornerRadius(_ radius: CGFloat) -> Self {
        layer.cornerRadius = radius
        layer.masksToBounds = true
        return self
    }

    /// 设置部分圆角
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    /// 圆形
    @discardableResult
    func asCircle() -> Self {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        layer.masksToBounds = true
        return self
    }

    // MARK: - 边框

    /// 设置边框
    @discardableResult
    func border(width: CGFloat, color: UIColor) -> Self {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        return self
    }

    // MARK: - 阴影

    /// 设置阴影
    @discardableResult
    func shadow(
        color: UIColor = .black,
        opacity: Float = 0.1,
        offset: CGSize = CGSize(width: 0, height: 2),
        radius: CGFloat = 4
    ) -> Self {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
        return self
    }

    /// 移除阴影
    func removeShadow() {
        layer.shadowOpacity = 0
    }

    // MARK: - 渐变

    /// 添加渐变背景
    @discardableResult
    func gradient(
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0, y: 0),
        endPoint: CGPoint = CGPoint(x: 1, y: 1)
    ) -> Self {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        layer.insertSublayer(gradientLayer, at: 0)
        return self
    }

    // MARK: - 动画

    /// 淡入
    func fadeIn(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: { _ in completion?() })
    }

    /// 淡出
    func fadeOut(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
            completion?()
        })
    }

    /// 抖动动画
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-10, 10, -8, 8, -5, 5, -2, 2, 0]
        layer.add(animation, forKey: "shake")
    }

    // MARK: - 截图

    /// 生成截图
    var screenshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // MARK: - 层级

    /// 获取所有父视图
    var superviews: [UIView] {
        var views: [UIView] = []
        var view = superview
        while let v = view {
            views.append(v)
            view = v.superview
        }
        return views
    }

    /// 获取所有子视图（递归）
    var allSubviews: [UIView] {
        subviews + subviews.flatMap { $0.allSubviews }
    }

    /// 移除所有子视图
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - 手势

    /// 添加点击手势
    @discardableResult
    func onTap(_ action: @escaping () -> Void) -> UITapGestureRecognizer {
        isUserInteractionEnabled = true
        let tap = TapGestureRecognizer(action: action)
        addGestureRecognizer(tap)
        return tap
    }
}

// MARK: - 手势辅助类

private class TapGestureRecognizer: UITapGestureRecognizer {
    private var action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap))
    }

    @objc private func handleTap() {
        action()
    }
}
