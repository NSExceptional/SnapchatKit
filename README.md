# SnapchatKit

[![Version](https://img.shields.io/cocoapods/v/SnapchatKit.svg?style=flat)](http://cocoapods.org/pods/SnapchatKit)
[![License](https://img.shields.io/cocoapods/l/SnapchatKit.svg?style=flat)](http://cocoapods.org/pods/SnapchatKit)
[![Platform](https://img.shields.io/cocoapods/p/SnapchatKit.svg?style=flat)](http://cocoapods.org/pods/SnapchatKit)
[![Issues](https://img.shields.io/github/issues-raw/ThePantsThief/SnapchatKit.svg?style=flat)](https://github.com//ThePantsThief/SnapchatKit/issues)
[![Stars](https://img.shields.io/github/stars/ThePantsThief/SnapchatKit.svg?style=flat)](https://github.com//ThePantsThief/SnapchatKit/stargazers)

## Quick FAQ
> How do I get login and stuff working?

SnapchatKit relies on Liam Cottle's private API to sign in *and* make any request, due to how the iOS API works and the limits of our knowledge of its implementation. His API is now public again. Head over to the [Casper developer page](https://developers.casper.io) to get started. **Disclaimer: it is not cheap. If you don't know what you're doing or if you're not super serious about using this kit, you should just leave now.**

> What is `Login.h` / why is it missing?

It's just a file I keep my credentials in on my computer. You can safely remove any references to it, and any mysterious constants like `kUsername` or `kAuthToken` which are defined in `Login.h`.

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
[SKClient sharedClient].casperAPIKey = @"your_api_key";
[SKClient sharedClient].casperAPISecret = @"your_api_secret";
[SKClient sharedClient].casperUserAgent = @"not_required_but_please_use_one";
[[SKClient sharedClient] signInWithUsername:@"donald-trump" password:@"for_president"
                                 completion:^(NSDictionary *json, NSError *error) {
    NSArray *unread = [SKClient sharedClient].currentSession.unread;
    NSLog(@"%@", unread);
}];
```

~~Gmail information is necessary to trick Snapchat into thinking we're using the first-party Android client.~~
SnapchatKit now poses as the iOS client instead of the Android one; Google credentials not required.

## To-do
- TLS chat support
- Tests

## Third party resources

- https://gibsonsec.org/snapchat/fulldisclosure/
- https://github.com/mgp25/SC-API/wiki/API-v2-Research/
- https://github.com/mgp25/SC-API/
- ~~https://github.com/liamcottle/AttestationServlet~~ unused now but still useful to know

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
