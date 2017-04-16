Pod::Spec.new do |s|

  s.name         = "remote-controllable"
  s.version      = "0.1.4"
  s.summary      = "Enable remote control of application"

  s.description  = <<-DESC
                     Used in connection with websocket server to enable remote controll of app
                     Features:
                     1. Connects to socket server broadcasting the need for support
                     2. Transmits screenshots to agents who accept the support request
                     3. Allows support agents to highlight features on screen by drawing on the users screen
                     4. Alerts users to the remote session by drawing a red box around the screen
                   DESC

  s.homepage         = "http://www.alexandra.dk"

  s.license         = { :type => 'aGPL', :file => 'LICENSE' }
  s.author          = { "Thomas Gilbert" => "thomas.gilbert@alexandra.dk" }

  s.social_media_url   = "http://twitter.com/thomasbjgilbert"

  s.platform     = :ios, "10.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :git => "https://github.com/glagnar/remote-controllable.git", :tag => "#{s.version}" }
  s.source_files  = 'Pod/Classes/**/*'

  s.requires_arc = true

  s.dependency "Socket.IO-Client-Swift", "~> 8.3.3"

end
