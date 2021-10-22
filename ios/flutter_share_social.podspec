#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_share_social.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_share_social'
  s.version          = '0.1'
  s.summary          = 'Share to Facebook and Zalo Flutter plugin.'
  s.description      = <<-DESC
  Share to Facebook and Zalo Flutter plugin..
                       DESC
  s.homepage         = 'http://namndev.github.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'namndev' => 'namnd.bka@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'FBSDKCoreKit', '12.0.2'
  s.dependency 'FBSDKShareKit', '12.0.2'

  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  # s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
