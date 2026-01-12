Pod::Spec.new do |s|
  s.name             = 'YFExtensions'
  s.version          = '1.0.0'
  s.summary          = 'iOS 常用扩展集合'

  s.description      = <<-DESC
    YFExtensions 提供常用的 Swift 扩展，支持子模块按需引入：
    - Foundation: String、Date、Array、Dictionary
    - UIKit: UIView、UIImage、UIViewController
    - Color: UIColor 扩展
  DESC

  s.homepage         = 'https://github.com/syyjay/YFComponents'
  s.license          = { :type => 'MIT' }
  s.author           = { 'syyjay' => 'syyjay@sina.cn' }
  s.source           = { :git => 'https://github.com/syyjay/YFComponents.git', :tag => "YFExtensions-#{s.version.to_s}" }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  # 默认引入所有子模块
  s.default_subspecs = 'Foundation', 'UIKit', 'Color'

  # Foundation 扩展
  s.subspec 'Foundation' do |ss|
    ss.source_files = 'Classes/Foundation/**/*'
  end

  # UIKit 扩展（不含 Color）
  s.subspec 'UIKit' do |ss|
    ss.source_files = 'Classes/UIKit/UIView+YF.swift',
                      'Classes/UIKit/UIImage+YF.swift',
                      'Classes/UIKit/UIViewController+YF.swift'
  end

  # Color 扩展（独立子模块）
  s.subspec 'Color' do |ss|
    ss.source_files = 'Classes/UIKit/UIColor+YF.swift'
  end
end
