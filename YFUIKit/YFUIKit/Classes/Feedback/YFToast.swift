//
//  YFToast.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit
import SnapKit

// MARK: - Toast Type

/// Toast 类型
public enum YFToastType {
    case info       // 普通信息
    case success    // 成功
    case error      // 错误
    case warning    // 警告
    
    var icon: UIImage? {
        switch self {
        case .info:
            return UIImage(systemName: "info.circle.fill")
        case .success:
            return UIImage(systemName: "checkmark.circle.fill")
        case .error:
            return UIImage(systemName: "xmark.circle.fill")
        case .warning:
            return UIImage(systemName: "exclamationmark.triangle.fill")
        }
    }
    
    var color: UIColor {
        switch self {
        case .info:
            return .themed(\.textPrimary)
        case .success:
            return .themed(\.success)
        case .error:
            return .themed(\.error)
        case .warning:
            return .themed(\.warning)
        }
    }
}

// MARK: - Toast Position

/// Toast 位置
public enum YFToastPosition {
    case top
    case center
    case bottom
}

// MARK: - YFToast

/// Toast 轻提示
public final class YFToast {
    
    // MARK: - Properties
    
    private static var currentToast: YFToastView?
    
    /// 默认显示时长
    public static var defaultDuration: TimeInterval = 2.0
    
    /// 默认位置
    public static var defaultPosition: YFToastPosition = .center
    
    /// 默认是否显示图标
    public static var defaultShowIcon: Bool = true
    
    // MARK: - Show Methods
    
    /// 显示 Toast
    /// - Parameters:
    ///   - message: 提示文字
    ///   - type: 类型（info/success/error/warning）
    ///   - position: 位置（top/center/bottom）
    ///   - duration: 显示时长
    ///   - showIcon: 是否显示图标
    ///   - view: 显示在哪个视图上
    public static func show(
        _ message: String,
        type: YFToastType = .info,
        position: YFToastPosition? = nil,
        duration: TimeInterval? = nil,
        showIcon: Bool? = nil,
        in view: UIView? = nil
    ) {
        DispatchQueue.main.async {
            let targetView = view ?? YFApp.keyWindow
            guard let containerView = targetView else { return }
            
            // 隐藏当前 Toast
            hideCurrentToast()
            
            // 创建新 Toast
            let shouldShowIcon = showIcon ?? defaultShowIcon
            let toast = YFToastView(message: message, type: type, showIcon: shouldShowIcon)
            currentToast = toast
            
            containerView.addSubview(toast)
            
            // 设置位置
            let pos = position ?? defaultPosition
            toast.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.left.greaterThanOrEqualToSuperview().offset(40)
                make.right.lessThanOrEqualToSuperview().offset(-40)
                
                switch pos {
                case .top:
                    make.top.equalTo(containerView.safeAreaLayoutGuide).offset(20)
                case .center:
                    make.centerY.equalToSuperview()
                case .bottom:
                    make.bottom.equalTo(containerView.safeAreaLayoutGuide).offset(-60)
                }
            }
            
            // 动画显示
            toast.alpha = 0
            toast.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
                toast.alpha = 1
                toast.transform = .identity
            }
            
            // 自动隐藏
            let dur = duration ?? defaultDuration
            DispatchQueue.main.asyncAfter(deadline: .now() + dur) {
                hide(toast)
            }
        }
    }
    
    /// 显示纯文字提示（无图标）
    public static func text(_ message: String, position: YFToastPosition? = nil, duration: TimeInterval? = nil) {
        show(message, type: .info, position: position, duration: duration, showIcon: false)
    }
    
    /// 显示成功提示
    public static func success(_ message: String, duration: TimeInterval? = nil) {
        show(message, type: .success, duration: duration)
    }
    
    /// 显示错误提示
    public static func error(_ message: String, duration: TimeInterval? = nil) {
        show(message, type: .error, duration: duration)
    }
    
    /// 显示警告提示
    public static func warning(_ message: String, duration: TimeInterval? = nil) {
        show(message, type: .warning, duration: duration)
    }
    
    // MARK: - Hide
    
    private static func hide(_ toast: YFToastView) {
        guard toast.superview != nil else { return }
        
        UIView.animate(withDuration: 0.2) {
            toast.alpha = 0
            toast.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            toast.removeFromSuperview()
            if currentToast === toast {
                currentToast = nil
            }
        }
    }
    
    private static func hideCurrentToast() {
        if let toast = currentToast {
            toast.removeFromSuperview()
            currentToast = nil
        }
    }
    
    /// 隐藏所有 Toast
    public static func hideAll() {
        hideCurrentToast()
    }
    
}

// MARK: - Toast View

private class YFToastView: UIView {
    
    private var theme: YFTheme { YFThemeManager.shared.theme }
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private lazy var iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    init(message: String, type: YFToastType, showIcon: Bool = true) {
        super.init(frame: .zero)
        setupUI()
        configure(message: message, type: type, showIcon: showIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        layer.cornerRadius = 8
        
        addSubview(stackView)
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(messageLabel)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        }
        
        iconView.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
    }
    
    private func configure(message: String, type: YFToastType, showIcon: Bool) {
        messageLabel.text = message
        
        if showIcon, let icon = type.icon {
            iconView.image = icon
            iconView.tintColor = type.color
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }
    }
}

// MARK: - UIView Extension

public extension UIView {
    
    /// 在视图上显示 Toast
    func yf_showToast(_ message: String, type: YFToastType = .info, position: YFToastPosition = .center, showIcon: Bool = true) {
        YFToast.show(message, type: type, position: position, showIcon: showIcon, in: self)
    }
    
    /// 纯文字 Toast
    func yf_showText(_ message: String, position: YFToastPosition = .center) {
        YFToast.text(message, position: position)
    }
    
    func yf_showSuccess(_ message: String) {
        YFToast.show(message, type: .success, in: self)
    }
    
    func yf_showError(_ message: String) {
        YFToast.show(message, type: .error, in: self)
    }
}

// MARK: - UIViewController Extension

public extension UIViewController {
    
    /// 显示 Toast
    func showToast(_ message: String, type: YFToastType = .info, position: YFToastPosition = .center, showIcon: Bool = true) {
        YFToast.show(message, type: type, position: position, showIcon: showIcon, in: view)
    }
    
    /// 纯文字 Toast
    func showText(_ message: String, position: YFToastPosition = .center) {
        YFToast.text(message, position: position)
    }
    
    func showSuccess(_ message: String) {
        YFToast.success(message)
    }
    
    func showError(_ message: String) {
        YFToast.error(message)
    }
    
    func showWarning(_ message: String) {
        YFToast.warning(message)
    }
}
