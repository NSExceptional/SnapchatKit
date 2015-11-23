# SnapchatKit

[![Version](https://img.shields.io/cocoapods/v/SnapchatKit.svg?style=flat)](http://cocoapods.org/pods/SnapchatKit)
[![License](https://img.shields.io/cocoapods/l/SnapchatKit.svg?style=flat)](http://cocoapods.org/pods/SnapchatKit)
[![Platform](https://img.shields.io/cocoapods/p/SnapchatKit.svg?style=flat)](http://cocoapods.org/pods/SnapchatKit)
[![Issues](https://img.shields.io/github/issues-raw/ThePantsThief/SnapchatKit.svg?style=flat)](https://github.com//ThePantsThief/SnapchatKit/issues)
[![Stars](https://img.shields.io/github/stars/ThePantsThief/SnapchatKit.svg?style=flat)](https://github.com//ThePantsThief/SnapchatKit/stargazers)

## Usage

Documentation for SnapchatKit is on [Cocoadocs](http://cocoadocs.org/docsets/SnapchatKit/0.1.0/index.html). To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

Add SnapchatKit to your podfile:

```ruby
pod 'SnapchatKit'
```

Or add the source files in /Pods to your project, ~~as well as SSZipArchive~~. SnapchatKit does depend on SSZipArchive, but its Cocoapod version is a version behind it's actual version, which SnapchatKit uses. I have included the required source files in the meantime.

## Examples

SnapchatKit revolves around the `SKClient` class as a singleton. An instance of `SKClient` manages a Snapchat account. Here, we sign in and get a list of unread snaps and chats:

```objc
[[SKClient sharedClient] signInWithUsername:@"donald-trump" password:@"for_president"
                                      gmail:@"niceHair@gmail.com" gpass:@"123abc"
                                 completion:^(NSDictionary *json) {
    NSArray *unread = [SKClient sharedClient].currentSession.unread;
    NSLog(@"%@", unread);
}];
```

Gmail information is necessary to trick Snapchat into thinking we're using the first-party Android client.

## To-do
- TLS chat support
- Send Google account passwords encrypted instead of plaintext...
- Tests

## Third party resources

- https://gibsonsec.org/snapchat/fulldisclosure/
- https://github.com/mgp25/SC-API/wiki/API-v2-Research/
- https://github.com/mgp25/SC-API/
- https://github.com/liamcottle/AttestationServlet

## Special thanks to

- Everyone who built and maintains the [PHP implementation](https://github.com/mgp25/SC-API/).
- [Liam Cottle](https://github.com/liamcottle), for sharing some code used in his app, Casper.
- Steve, who also worked on the PHP implementation.
- Harry "The Man" Gulliford.
- Sam Symons, author of [RedditKit](https://github.com/samsymons/RedditKit).
- Those unmentioned, you know who you are. Thank you.

## Author

ThePantsThief, tannerbennett@me.com, [/u/ThePantsThief](http://www.reddit.com/user/thepantsthief/submitted)

## License

SnapchatKit is available under the MIT license. See the LICENSE file for more info.

## Legal

I'm fairly certain it's 100% legal to use a "private" REST API, and that there are no laws explicitly prohibiting the use of "private" REST APIs. However, this does not mean that the makers of these private APIs can't try to sue you under something overly-broad, such as the CFAA. I don't think Snapchat will, personally; in my experience they've only gone after developers for copyright disputes.

Disclaimer: The name "Snapchat" is a copyright of Snapchat™, Inc. This project is in no way affiliated with, sponsored, or endorsed by Snapchat™, Inc. I, the project owner and creator, am not responsible for any legalities that may arise in the use of this project. Use at your own risk.
