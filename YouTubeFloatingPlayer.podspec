
Pod::Spec.new do |s|
  s.name             = 'YouTubeFloatingPlayer'
  s.version          = '1.0.4'
  s.summary          = 'Youtube-styled Floating Player written in Swift'

  s.description      = <<-DESC
    A floating video player, similar to the one used in the YouTube app, written in Swift 3. This player is interactive in nature: drag to minimize, swipe to dismiss. Furthermore, it supports TableView as well as any other UIView underneath the video player while the player is in normal mode.
                        DESC

  s.homepage         = 'https://github.com/advaita13/YouTubeFloatingPlayer'
  s.license          = { :type => 'GNU GPLv3', :file => 'LICENSE' }
  s.author           = { 'Advaita Pandya' => 'adipandya@gmail.com' }
  s.source           = { :git => 'https://github.com/advaita13/YouTubeFloatingPlayer.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Source/YouTubeFloatingPlayer/Classes/**/*'
  s.resource_bundles = {
    'YouTubeFloatingPlayer' => ['Source/YouTubeFloatingPlayer/Resources/**/*.{xib,xcassets,imageset,png}']
  }

  s.dependency 'youtube-ios-player-helper'
end
