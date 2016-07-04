Pod::Spec.new do |s|
s.name             = "SnapchatKit"
s.version          = "1.0.0"
s.summary          = "An Objective-C implementation of the unofficial Snapchat API."
s.homepage         = "https://github.com/ThePantsThief/SnapchatKit"
s.license          = 'MIT'
s.author           = { "ThePantsThief" => "tannerbennett@me.com" }
s.source           = { :git => "https://github.com/ThePantsThief/SnapchatKit.git", :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/ThePantsThief'

s.requires_arc = true
s.ios.deployment_target = '7.0'
s.osx.deployment_target = '10.9'

s.source_files = 'Pod/Classes/*', 'Pod/Classes/**/*', 'Pod/Dependencies/*', 'Pod/Dependencies/**/*'
# s.dependency 'SSZipArchive'
s.dependency 'CocoaAsyncSocket'
s.dependency 'Mantle', '~> 2.0'
s.dependency 'TBURLRequestOptions'
s.library = 'z'
end
