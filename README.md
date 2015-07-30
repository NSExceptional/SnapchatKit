# SnapchatKit

[![Version](https://img.shields.io/cocoapods/v/SnapchatKit.svg?style=flat)](http://cocoapods.org/pods/SnapchatKit)
[![License](https://img.shields.io/cocoapods/l/SnapchatKit.svg?style=flat)](http://cocoapods.org/pods/SnapchatKit)
[![Platform](https://img.shields.io/cocoapods/p/SnapchatKit.svg?style=flat)](http://cocoapods.org/pods/SnapchatKit)
[![Issues](https://img.shields.io/github/issues-raw/ThePantsThief/SnapchatKit.svg?style=flat)](https://github.com//ThePantsThief/SnapchatKit/issues)
[![Stars](https://img.shields.io/github/stars/ThePantsThief/SnapchatKit.svg?style=flat)](https://github.com//ThePantsThief/SnapchatKit/stargazers)

## Usage

Documentation for MirrorKit is on [Cocoadocs](http://cocoadocs.org/docsets/SnapchatKit/0.1.0/index.html). To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

Add SnapchatKit to your podfile:

```ruby
pod 'SnapchatKit'
```

Or add the source files in /Pods to your project, as well as AFNetworking and SSZipArchive.

## Examples

SnapchatKit revolves around the `SKClient` class as a singleton. An instance of `SKClient` manages a Snapchat account. Here, we sign in and get a list of unread snaps and chats:

```objc
[[SKClient sharedClient] signInWithUsername:@"donald-trump" password:@"for_president" gmail:@"niceHair@gmail.com" gpass:@"123abc" completion:^(NSDictionary *json) {
    NSArray *unread = [SKClient sharedClient].currentSession.unread;
    NSLog(@"%@", unread);
}];
```

## To-do
- TLS chat support
- Send Google account passwords encrypted instead of plaintext...
- Tests

## Third party resources

- https://gibsonsec.org/snapchat/fulldisclosure/
- https://github.com/mgp25/SC-API/wiki/API-v2-Research/
- https://github.com/mgp25/SC-API/

## Special thanks to

- Everyone who built and maintains the [PHP implementation](https://github.com/mgp25/SC-API/).
- Steve, who also worked on the PHP implementation.
- Harry "The Man" Gulliford
- Sam Symons, author of [RedditKit](https://github.com/samsymons/RedditKit).

## Author

ThePantsThief, tannerbennett@me.com

## License

SnapchatKit is available under the MIT license. See the LICENSE file for more info.
