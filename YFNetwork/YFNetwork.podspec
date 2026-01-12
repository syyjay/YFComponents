Pod::Spec.new do |s|
  s.name             = 'YFNetwork'
  s.version          = '1.0.0'
  s.summary          = '基于 Moya 的易用网络请求封装'

  s.description      = <<-DESC
    YFNetwork 基于 Moya 封装，提供：
    - 链式 API，简洁易用
    - 灵活设置请求参数
    - 泛型响应解析（Codable）
    - Async/Await 支持
  DESC

  s.homepage         = 'https://github.com/syyjay/YFComponents'
  s.license          = { :type => 'MIT' }
  s.author           = { 'syyjay' => 'syyjay@sina.cn' }
  s.source           = { :git => 'https://github.com/syyjay/YFComponents.git', :tag => "YFNetwork-#{s.version.to_s}" }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'YFNetwork/YFNetwork/Classes/**/*'

  s.dependency 'Moya', '~> 15.0'
  s.dependency 'YFLogger'
end
