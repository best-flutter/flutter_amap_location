#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'amap_location'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin to use amap location.高德地图定位组件'
  s.description      = <<-DESC
A Flutter plugin to use amap location.高德地图定位组件
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'JZoom' => 'jzoom8112@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'AMapLocation'
  s.static_framework = true
  s.ios.deployment_target = '8.0'
end

