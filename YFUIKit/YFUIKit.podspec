Pod::Spec.new do |s|
  s.name             = 'YFUIKit'
  s.version          = '1.0.0'
  s.summary          = 'iOS 通用 UI 组件库'

  s.description      = <<-DESC
    YFUIKit 是一个功能丰富的 iOS UI 组件库，包含：
    - 主题系统
    - 按钮组件
    - Toast 提示
    - 空状态视图
    等通用 UI 组件
  DESC

  s.homepage         = 'https://github.com/syyjay/YFComponents'
  s.license          = { :type => 'MIT' }
  s.author           = { 'syyjay' => 'syyjay@sina.cn' }
  s.source           = { :git => 'https://github.com/syyjay/YFComponents.git', :tag => "YFUIKit-#{s.version.to_s}" }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'Classes/**/*'

  s.resource_bundles = {
    'YFUIKit' => ['Assets/**/*.{png,xcassets,json}']
  }

  s.dependency 'SnapKit', '~> 5.0'
  s.dependency 'YFExtensions/Color'
end

