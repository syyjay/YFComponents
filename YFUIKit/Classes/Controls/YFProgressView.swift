//
//  YFProgressView.swift
//  YFUIKit
//
//  环形进度视图
//

import UIKit

/// 环形进度视图
public class YFProgressView: UIView {
    
    // MARK: - Properties
    
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private var theme: YFTheme { YFThemeManager.shared.theme }
    
    /// 轨道颜色
    public var trackColor: UIColor = .themed(\.divider) {
        didSet { trackLayer.strokeColor = trackColor.cgColor }
    }
    
    /// 进度颜色
    public var progressColor: UIColor = .themed(\.primary) {
        didSet { progressLayer.strokeColor = progressColor.cgColor }
    }
    
    /// 线宽
    public var lineWidth: CGFloat = 4 {
        didSet {
            trackLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
        }
    }
    
    /// 当前进度 (0-1)
    public private(set) var progress: Float = 0
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }
    
    // MARK: - Setup
    
    private func setupLayers() {
        backgroundColor = .clear
        
        // 轨道
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        // 进度
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    private func updatePath() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }
    
    // MARK: - Public
    
    /// 设置进度
    public func setProgress(_ progress: Float, animated: Bool = true) {
        let value = min(max(progress, 0), 1)
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = CGFloat(value)
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "progress")
        }
        
        self.progress = value
        progressLayer.strokeEnd = CGFloat(value)
    }
}
