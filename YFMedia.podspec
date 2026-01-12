Pod::Spec.new do |s|
  s.name             = 'YFMedia'
  s.version          = '1.1.0'
  s.summary          = '轻量级媒体选择和处理库'
  s.description      = '图片/视频选择、拍照、裁剪、压缩、预览'
  s.homepage         = 'https://github.com/syyjay/YFComponents'
  s.license          = { :type => 'MIT' }
  s.author           = { 'syyjay' => 'syyjay@sina.cn' }
  s.source           = { :git => 'https://github.com/syyjay/YFComponents.git', :tag => "YFMedia-#{s.version.to_s}" }
  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'
  s.source_files = 'YFMedia/Classes/**/*'
  s.frameworks = 'UIKit', 'Photos', 'PhotosUI', 'AVFoundation'

  s.dependency 'YFUIKit'
  s.dependency 'YFExtensions'
  s.dependency 'YFLogger'
end
