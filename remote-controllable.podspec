#
# Be sure to run `pod lib lint remote-controllable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "remote-controllable"
  s.version          = "0.0.2"
  s.summary          = "Enable remote control of application"

  s.homepage         = "http://www.alexandra.dk"
  s.license          = 'aGPL'
  s.author           = { "Thomas Gilbert" => "thomas.gilbert@alexandra.dk" }
  s.source           = { :git => "https://github.com/glagnar/remote-controllable.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'remote-controllable' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'Socket.IO-Client-Swift'
end
