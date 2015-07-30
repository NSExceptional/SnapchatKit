#
# Be sure to run `pod lib lint SnapchatKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SnapchatKit"
  s.version          = "0.1.0"
  s.summary          = "An Objective-C implementation of the unofficial Snapchat API."
  s.homepage         = "https://github.com/ThePantsThief/SnapchatKit"
  s.license          = 'MIT'
  s.author           = { "ThePantsThief" => "tannerbennett@me.com" }
  s.source           = { :git => "https://github.com/ThePantsThief/SnapchatKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ThePantsThief'

  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Pod/Classes/*', 'Pod/Classes/**/*'
  s.dependency 'AFNetworking', '~> 2.5'
  s.dependency 'SSZipArchive'
end
