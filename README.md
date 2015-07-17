[![Issues](https://img.shields.io/github/issues-raw/ThePantsThief/SnapchatKit.svg?style=flat)](https://github.com//ThePantsThief/SnapchatKit/issues)
[![Stars](https://img.shields.io/github/stars/ThePantsThief/SnapchatKit.svg?style=flat)](https://github.com//ThePantsThief/SnapchatKit/stargazers)

# SnapchatKit
An Objective-C implementation of the unofficial Snapchat API. Inspired by [RedditKit](https://github.com/samsymons/RedditKit). Work in progress!

WIP [Snapchat API documentation](https://github.com/ThePantsThief/SnapchatKit/blob/master/SK-API-Docs.md), with the help of everything below.

## Installation
- Add the `Classes` and `External` folders to your project
- In your project file under "Build Phases" link with `libz.dylib` (might appear as `libz.1.dylib` or something)
- `#import "SnapchatKit.h"` wherever you need to use it!

## To-do
- Link to AFNetworking somehow instead of just copying the files, like RedditKit does (github is hard ok)
- TLS chat support
- Send Google account passwords encrypted instead of plaintext... code coming in ~2 weeks
- Cocoapods support
- MIT License

## Third party resources

- http://gibsonsec.org/snapchat/fulldisclosure/
- https://github.com/mgp25/SC-API/wiki/API-v2-Research/
- https://github.com/mgp25/SC-API/

## Special thanks to

- Everyone who built and maintains the [PHP implementation](https://github.com/mgp25/SC-API/).
- Steve, who also worked on the PHP implementation.
- Harry "The Man" Gulliford
- Sam Symons, author of [RedditKit](https://github.com/samsymons/RedditKit).
