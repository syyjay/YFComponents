Pod::Spec.new do |s|
  s.name             = 'YFRouter'
  s.version          = '1.0.0'
  s.summary          = '轻量级路由框架'
  s.description      = '支持页面注册、参数传递、拦截器、URL Scheme 的轻量级路由框架'
  s.homepage         = 'https://github.com/syyjay/YFComponents'
  s.license          = { :type => 'MIT' }
  s.author           = { 'syyjay' => 'syyjay@sina.cn' }
  s.source           = { :git => 'https://github.com/syyjay/YFComponents.git', :tag => "YFRouter-#{s.version.to_s}" }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'Classes/**/*'
  s.dependency 'YFLogger'
end
