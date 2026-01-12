//
//  YFSwitch.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 自定义 Switch - 支持主题
///
/// 默认使用 `.themed()` 颜色，主题切换时自动更新
open class YFSwitch: UISwitch {
    
    public var theme: YFTheme { YFThemeManager.shared.theme }
    
    private var valueChangedAction: ((Bool) -> Void)?
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public convenience init(_ isOn: Bool = false) {
        self.init(frame: .zero)
        self.isOn = isOn
    }
    
    private func setup() {
        onTintColor = .themed(\.primary)
        addTarget(self, action: #selector(handleChange), for: .valueChanged)
    }
    
    @objc private func handleChange() {
        valueChangedAction?(isOn)
    }
    
    // MARK: - 链式调用
    
    @discardableResult
    public func isOn(_ on: Bool) -> Self {
        self.isOn = on
        return self
    }
    
    @discardableResult
    public func onColor(_ color: UIColor) -> Self {
        onTintColor = color
        return self
    }
    
    @discardableResult
    public func onChange(_ action: @escaping (Bool) -> Void) -> Self {
        valueChangedAction = action
        return self
    }
}
