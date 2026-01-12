//
//  YFAlertController+Convenience.swift
//  YFUIKit
//
//  弹窗便捷静态方法
//

import UIKit

// MARK: - 便捷静态方法

public extension YFAlertController {
    
    /// 简单提示
    static func alert(
        title: String?,
        message: String? = nil,
        confirmTitle: String = "确定",
        handler: (() -> Void)? = nil
    ) {
        let alert = YFAlertController(style: .alert)
            .title(title)
            .message(message)
            .addAction(.confirm(confirmTitle, handler: handler))
        alert.show()
    }
    
    /// 确认弹窗
    static func confirm(
        title: String?,
        message: String? = nil,
        cancelTitle: String = "取消",
        confirmTitle: String = "确定",
        destructive: Bool = false,
        onCancel: (() -> Void)? = nil,
        onConfirm: @escaping () -> Void
    ) {
        let alert = YFAlertController(style: .alert)
            .title(title)
            .message(message)
            .addAction(.cancel(cancelTitle, handler: onCancel))
        
        if destructive {
            alert.addAction(.destructive(confirmTitle, handler: onConfirm))
        } else {
            alert.addAction(.confirm(confirmTitle, handler: onConfirm))
        }
        
        alert.show()
    }
    
    /// 输入弹窗
    static func prompt(
        title: String?,
        message: String? = nil,
        placeholder: String? = nil,
        defaultText: String? = nil,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        cancelTitle: String = "取消",
        confirmTitle: String = "确定",
        onConfirm: @escaping (String) -> Void
    ) {
        let alert = YFAlertController(style: .alert)
            .title(title)
            .message(message)
            .addTextField(YFAlertTextField(
                placeholder: placeholder,
                text: defaultText,
                keyboardType: keyboardType,
                isSecureTextEntry: isSecure
            ))
            .addAction(.cancel(cancelTitle))
        
        // 确认时获取输入内容
        let confirmAction = YFAlertAction(confirmTitle, style: .default) { [weak alert] in
            let text = alert?.textFields.first?.text ?? ""
            onConfirm(text)
        }
        alert.actions.append(confirmAction)
        
        alert.show()
    }
    
    /// ActionSheet
    static func actionSheet(
        title: String? = nil,
        message: String? = nil,
        actions: [YFAlertAction],
        cancelTitle: String = "取消"
    ) {
        let alert = YFAlertController(style: .actionSheet)
            .title(title)
            .message(message)
        
        for action in actions {
            alert.addAction(action)
        }
        
        alert.addAction(.cancel(cancelTitle))
        alert.show()
    }
    
    /// 自定义内容弹窗
    static func custom(
        _ contentView: UIView,
        style: YFAlertStyle = .alert,
        dismissable: Bool = true,
        actions: [YFAlertAction] = []
    ) {
        let alert = YFAlertController(style: style)
            .customContent(contentView)
            .dismissable(dismissable)
        
        for action in actions {
            alert.addAction(action)
        }
        
        alert.show()
    }
}

// MARK: - UIViewController Extension

public extension UIViewController {
    
    /// 显示提示弹窗
    func yf_alert(_ title: String?, message: String? = nil, handler: (() -> Void)? = nil) {
        YFAlertController.alert(title: title, message: message, handler: handler)
    }
    
    /// 显示确认弹窗
    func yf_confirm(_ title: String?, message: String? = nil, onConfirm: @escaping () -> Void) {
        YFAlertController.confirm(title: title, message: message, onConfirm: onConfirm)
    }
    
    /// 显示危险确认弹窗
    func yf_confirmDestructive(
        _ title: String?,
        message: String? = nil,
        confirmTitle: String = "删除",
        onConfirm: @escaping () -> Void
    ) {
        YFAlertController.confirm(
            title: title,
            message: message,
            confirmTitle: confirmTitle,
            destructive: true,
            onConfirm: onConfirm
        )
    }
    
    /// 显示输入弹窗
    func yf_prompt(_ title: String?, placeholder: String? = nil, onConfirm: @escaping (String) -> Void) {
        YFAlertController.prompt(title: title, placeholder: placeholder, onConfirm: onConfirm)
    }
    
    /// 显示 ActionSheet
    func yf_actionSheet(_ title: String? = nil, actions: [YFAlertAction]) {
        YFAlertController.actionSheet(title: title, actions: actions)
    }
}

