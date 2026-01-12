//
//  YFTextView.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 自定义 TextView - 支持占位符和链式调用
///
/// 默认使用 `.themed()` 颜色，主题切换时自动更新
open class YFTextView: UITextView {
    
    public var theme: YFTheme { YFThemeManager.shared.theme }
    
    /// 占位符
    public var placeholder: String? {
        didSet { placeholderLabel.text = placeholder }
    }
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = theme.typography.body
        label.textColor = .themed(\.textTertiary)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Init
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public convenience init(_ placeholder: String? = nil) {
        self.init(frame: .zero, textContainer: nil)
        self.placeholder = placeholder
        placeholderLabel.text = placeholder
    }
    
    private func setup() {
        font = theme.typography.body
        textColor = .themed(\.textPrimary)
        tintColor = .themed(\.primary)
        backgroundColor = .themed(\.backgroundSecondary)
        layer.cornerRadius = 8
        textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        
        addSubview(placeholderLabel)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.frame = CGRect(
            x: textContainerInset.left + textContainer.lineFragmentPadding,
            y: textContainerInset.top,
            width: bounds.width - textContainerInset.left - textContainerInset.right - textContainer.lineFragmentPadding * 2,
            height: bounds.height - textContainerInset.top - textContainerInset.bottom
        )
        placeholderLabel.sizeToFit()
    }
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    // MARK: - 链式调用
    
    @discardableResult
    public func placeholder(_ text: String) -> Self {
        placeholder = text
        return self
    }
    
    @discardableResult
    public func text(_ text: String) -> Self {
        self.text = text
        placeholderLabel.isHidden = !text.isEmpty
        return self
    }
    
    @discardableResult
    public func font(_ font: UIFont) -> Self {
        self.font = font
        placeholderLabel.font = font
        return self
    }
}
