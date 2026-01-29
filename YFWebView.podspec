Pod::Spec.new do |s|
  s.name             = 'YFWebView'
  s.version          = '1.3.1'
  s.summary          = 'WKWebView 封装，支持 JS 交互、进度条、Cookie 管理'
  s.description      = <<-DESC
    YFWebView 是基于 WKWebView 的封装库，提供：
    - 便捷的加载方法（URL/HTML/本地文件）
    - 加载进度条
    - JS 双向通信桥接
    - Cookie 管理
    - 自定义 UserAgent
    - URL 拦截处理
  DESC
  s.homepage         = 'https://github.com/syyjay/YFComponents'
  s.license          = { :type => 'MIT' }
  s.author           = { 'syyjay' => 'syyjay@sina.cn' }
  s.source           = { :git => 'https://github.com/syyjay/YFComponents.git', :tag => "YFWebView-#{s.version.to_s}" }
  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'
  s.source_files = 'YFWebView/Classes/**/*'

  s.dependency 'YFUIKit'
  s.dependency 'YFLogger'
  s.dependency 'SnapKit'
end
