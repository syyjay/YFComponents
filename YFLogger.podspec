Pod::Spec.new do |s|
  s.name             = 'YFLogger'
  s.version          = '1.3.0'
  s.summary          = '轻量级日志框架'
  s.description      = '支持分级日志、格式化输出、文件存储的轻量级日志框架'
  s.homepage         = 'https://github.com/syyjay/YFComponents'
  s.license          = { :type => 'MIT' }
  s.author           = { 'syyjay' => 'syyjay@sina.cn' }
  s.source           = { :git => 'https://github.com/syyjay/YFComponents.git', :tag => "YFLogger-#{s.version.to_s}" }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'YFLogger/Classes/**/*'
end
