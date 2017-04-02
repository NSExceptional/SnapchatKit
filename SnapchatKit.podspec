Pod::Spec.new do |s|
    s.name             = "SnapchatKit"
    s.version          = "1.1.0"
    s.summary          = "An Objective-C implementation of the unofficial Snapchat API."
    s.homepage         = "https://github.com/NSExceptional/SnapchatKit"
    s.license          = 'MIT'
    s.author           = { "NSExceptional" => "tannerbennett@me.com" }
    s.source           = { :git => "https://github.com/NSExceptional/SnapchatKit.git", :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/NSExceptional'

    s.requires_arc = true
    s.ios.deployment_target = '7.0'
    s.osx.deployment_target = '10.9'

    s.source_files = 'SnapchatKit/Classes/*', 'SnapchatKit/Classes/**/*', 'SnapchatKit/Dependencies/*', 'SnapchatKit/Dependencies/**/*'
    s.dependency 'CocoaAsyncSocket'
    s.dependency 'Mantle', '~> 2.0'
    s.dependency 'TBURLRequestOptions'
    s.library = 'z'
end
