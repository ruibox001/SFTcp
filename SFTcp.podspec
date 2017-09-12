Pod::Spec.new do |s|
s.name        = 'SFTcp'
s.version     = '1.0.1'
s.authors     = { 'ruibox001' => 'wangshengyuancrazy@163.com' }
s.homepage    = 'https://github.com/ruibox001/SFTcp'
s.summary     = 'SFTcp 是封装了Tcp请求类，使用方便，源码开放'
s.source      = { :git => 'https://github.com/ruibox001/SFTcp.git',:tag => "v#{s.version}" }
s.license     = { :type => "MIT", :file => "LICENSE" }
s.platform = :ios, '8.0'
s.requires_arc = true
s.source_files = 'SFTcp'
s.public_header_files = 'SFTcp/*.h'
s.framework  = "UIKit"
s.ios.deployment_target = '8.0'
end