Pod::Spec.new do |s|
  s.name             = 'YFStorage'
  s.version          = '1.3.1'
  s.summary          = '轻量级数据存储封装'

  s.description      = <<-DESC
    YFStorage 提供统一的数据存储接口：
    - UserDefaults 类型安全封装
    - Keychain 敏感数据存储
    - 磁盘缓存（支持过期时间）
  DESC

  s.homepage         = 'https://github.com/syyjay/YFComponents'
  s.license          = { :type => 'MIT' }
  s.author           = { 'syyjay' => 'syyjay@sina.cn' }
  s.source           = { :git => 'https://github.com/syyjay/YFComponents.git', :tag => "YFStorage-#{s.version.to_s}" }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'YFStorage/Classes/**/*'
end
