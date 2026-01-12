//
//  YFAlertModels.swift
//  YFUIKit
//
//  弹窗相关模型定义
//

import UIKit

// MARK: - Alert Style

/// 弹窗样式
public enum YFAlertStyle {
    case alert          // 居中弹窗
    case actionSheet    // 底部操作表
}

// MARK: - Alert Action

/// 弹窗按钮
public struct YFAlertAction {
    public let title: String
    public let style: Style
    public let handler: (() -> Void)?
    
    public enum Style {
        case `default`      // 默认样式
        case cancel         // 取消样式
        case destructive    // 危险样式
    }
    
    public init(_ title: String, style: Style = .default, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

// MARK: - Action 便捷创建

public extension YFAlertAction {
    
    static func `default`(_ title: String, handler: (() -> Void)? = nil) -> YFAlertAction {
        YFAlertAction(title, style: .default, handler: handler)
    }
    
    static func cancel(_ title: String = "取消", handler: (() -> Void)? = nil) -> YFAlertAction {
        YFAlertAction(title, style: .cancel, handler: handler)
    }
    
    static func destructive(_ title: String, handler: (() -> Void)? = nil) -> YFAlertAction {
        YFAlertAction(title, style: .destructive, handler: handler)
    }
    
    static func confirm(_ title: String = "确定", handler: (() -> Void)? = nil) -> YFAlertAction {
        YFAlertAction(title, style: .default, handler: handler)
    }
}

// MARK: - TextField Configuration

/// 输入框配置
public struct YFAlertTextField {
    public var placeholder: String?
    public var text: String?
    public var keyboardType: UIKeyboardType
    public var isSecureTextEntry: Bool
    
    public init(
        placeholder: String? = nil,
        text: String? = nil,
        keyboardType: UIKeyboardType = .default,
        isSecureTextEntry: Bool = false
    ) {
        self.placeholder = placeholder
        self.text = text
        self.keyboardType = keyboardType
        self.isSecureTextEntry = isSecureTextEntry
    }
}

