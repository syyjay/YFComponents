Pod::Spec.new do |s|
  s.name             = 'YFExtensions'
  s.version          = '1.3.1'
  s.summary          = 'iOS 常用扩展集合'

  s.description      = <<-DESC
    YFExtensions 提供常用的 Swift 扩展，支持子模块按需引入：
    - Foundation: String、Date、Array、Dictionary
  DESC

  s.homepage         = 'https://github.com/syyjay/YFComponents'
  s.license          = { :type => 'MIT' }
  s.author           = { 'syyjay' => 'syyjay@sina.cn' }
  s.source           = { :git => 'https://github.com/syyjay/YFComponents.git', :tag => "YFExtensions-#{s.version.to_s}" }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  # 默认引入所有子模块
  s.default_subspecs = 'Foundation'

  # Foundation 扩展
  s.subspec 'Foundation' do |ss|
    ss.source_files = 'YFExtensions/Classes/Foundation/**/*'
  end
end
