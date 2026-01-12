//
//  YFTypography.swift
//  YFUIKit
//
//  Created on 2024
//

import UIKit

/// 字体配置
public struct YFTypography {
    
    /// 大标题 - 34pt
    public var largeTitle: UIFont
    /// 标题1 - 28pt
    public var title1: UIFont
    /// 标题2 - 22pt
    public var title2: UIFont
    /// 标题3 - 20pt
    public var title3: UIFont
    /// 标题 - 17pt semibold
    public var headline: UIFont
    /// 正文 - 17pt
    public var body: UIFont
    /// 标注 - 16pt
    public var callout: UIFont
    /// 副标题 - 15pt
    public var subhead: UIFont
    /// 脚注 - 13pt
    public var footnote: UIFont
    /// 说明1 - 12pt
    public var caption1: UIFont
    /// 说明2 - 11pt
    public var caption2: UIFont
    
    public init(
        largeTitle: UIFont = .systemFont(ofSize: 34, weight: .bold),
        title1: UIFont = .systemFont(ofSize: 28, weight: .bold),
        title2: UIFont = .systemFont(ofSize: 22, weight: .bold),
        title3: UIFont = .systemFont(ofSize: 20, weight: .semibold),
        headline: UIFont = .systemFont(ofSize: 17, weight: .semibold),
        body: UIFont = .systemFont(ofSize: 17, weight: .regular),
        callout: UIFont = .systemFont(ofSize: 16, weight: .regular),
        subhead: UIFont = .systemFont(ofSize: 15, weight: .regular),
        footnote: UIFont = .systemFont(ofSize: 13, weight: .regular),
        caption1: UIFont = .systemFont(ofSize: 12, weight: .regular),
        caption2: UIFont = .systemFont(ofSize: 11, weight: .regular)
    ) {
        self.largeTitle = largeTitle
        self.title1 = title1
        self.title2 = title2
        self.title3 = title3
        self.headline = headline
        self.body = body
        self.callout = callout
        self.subhead = subhead
        self.footnote = footnote
        self.caption1 = caption1
        self.caption2 = caption2
    }
    
    /// 默认字体配置
    public static let `default` = YFTypography()
    
    /// 自定义字体族
    public static func custom(family: String) -> YFTypography {
        return YFTypography(
            largeTitle: UIFont(name: "\(family)-Bold", size: 34) ?? .systemFont(ofSize: 34, weight: .bold),
            title1: UIFont(name: "\(family)-Bold", size: 28) ?? .systemFont(ofSize: 28, weight: .bold),
            title2: UIFont(name: "\(family)-Bold", size: 22) ?? .systemFont(ofSize: 22, weight: .bold),
            title3: UIFont(name: "\(family)-Semibold", size: 20) ?? .systemFont(ofSize: 20, weight: .semibold),
            headline: UIFont(name: "\(family)-Semibold", size: 17) ?? .systemFont(ofSize: 17, weight: .semibold),
            body: UIFont(name: "\(family)-Regular", size: 17) ?? .systemFont(ofSize: 17, weight: .regular),
            callout: UIFont(name: "\(family)-Regular", size: 16) ?? .systemFont(ofSize: 16, weight: .regular),
            subhead: UIFont(name: "\(family)-Regular", size: 15) ?? .systemFont(ofSize: 15, weight: .regular),
            footnote: UIFont(name: "\(family)-Regular", size: 13) ?? .systemFont(ofSize: 13, weight: .regular),
            caption1: UIFont(name: "\(family)-Regular", size: 12) ?? .systemFont(ofSize: 12, weight: .regular),
            caption2: UIFont(name: "\(family)-Regular", size: 11) ?? .systemFont(ofSize: 11, weight: .regular)
        )
    }
}

