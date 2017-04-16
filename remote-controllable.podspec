#
# Be sure to run `pod lib lint remote-controllable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "remote-controllable"
  s.version          = "0.1.1"
  s.summary          = "Enable remote control of application"

  s.description = <<-DESC
                     Used in connection with websocket server to enable remote controll of app
                     Features:
                     1. Connects to socket server broadcasting the need for support
                     2. Transmits screenshots to agents who accept the support request
                     3. Allows support agents to highlight features on screen by drawing on the users screen
                     4. Alerts users to the remote session by drawing a red box around the screen
                   DESC

  s.homepage         = "http://www.alexandra.dk"
 
  s.license 	     = { :type => 'aGPL', :file => 'LICENSE' } 
  s.author           = { "Thomas Gilbert" => "thomas.gilbert@alexandra.dk" }
  s.source           = { :git => "https://github.com/glagnar/remote-controllable.git", :tag => s.version.to_s }

  s.platform     = :ios, '10.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'remote-controllable' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'Socket.IO-Client-Swift'
end
