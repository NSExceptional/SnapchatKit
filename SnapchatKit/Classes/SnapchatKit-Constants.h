//
//  SnapchatKit-Constants.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef UIKIT_EXTERN
#define kScreenWidth ((NSInteger)[UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ((NSInteger)[UIScreen mainScreen].bounds.size.height)
#else
#define kScreenWidth (640)
#define kScreenHeight (1136)
#endif

#define kDebugJSON YES
#define kVerboseLog YES

typedef void (^RequestBlock)(NSData *data, NSURLResponse *response, NSError *error);
typedef void (^DataBlock)(NSData *data, NSError *error);
typedef void (^StringBlock)(NSString *string, NSError *error);
typedef void (^DictionaryBlock)(NSDictionary *dict, NSError *error);
typedef void (^ArrayBlock)(NSArray *collection, NSError *error);
typedef void (^ResponseBlock)(id object, NSError *error);
typedef void (^VoidBlock)();

typedef NS_ENUM(NSInteger, SKAddSource)
{
    SKAddSourcePhonebook = 1,
    SKAddSourceUsername,
    SKAddSourceAddedBack
};

typedef NS_ENUM(NSInteger, SKMediaKind)
{
    SKMediaKindImage,
    SKMediaKindVideo,
    SKMediaKindSilentVideo,
    SKMediaKindFriendRequest,
    SKMediaKindStrangerImage,
    SKMediaKindStrangerVideo,
    SKMediaKindStrangerSilentVideo
};

typedef NS_ENUM(NSInteger, SKSnapStatus)
{
    SKSnapStatusNone       = -1,
    SKSnapStatusSent       = 0,
    SKSnapStatusDelivered  = 1,
    SKSnapStatusOpened     = 2,
    SKSnapStatusScreenshot = 3
};

typedef NS_ENUM(NSInteger, SKFriendStatus)
{
    SKFriendStatusConfirmed,
    SKFriendStatusUnconfirmed,
    SKFriendStatusBlocked,
    SKFriendStatusDeleted
};

typedef NS_ENUM(NSInteger, SKPrivacyStatus)
{
    SKPrivacyStatusEveryone,
    SKPrivacyStatusFriends
};

extern SKAddSource SKAddSourceFromString(NSString *addSourceString);
extern NSString * SKStringFromAddSource(SKAddSource addSource);

/** Before updating this value, confirm that the library requests everything in the same way as the app. */
extern NSString * const kUserAgent;
/** The API URL. iOS uses the /bq endpoint, Android clients use the /ph endpoint. */
extern NSString * const kURL;
/** The API secret used to create access tokens. */
extern NSString * const kSecret;
/** Used when no session is available. */
extern NSString * const kStaticToken;
/** Used to encrypt and decrypt media. */
extern NSString * const kBlobEncryptionKey;
/** Used to create the token for each request. */
extern NSString * const kHashPattern;

extern NSString * const kBoundary;

#pragma mark Header fields / values
extern NSString * const khfClientAuthTokenHeaderField;
extern NSString * const khfTimestamp;
extern NSString * const khfContentType;
extern NSString * const khfUserAgent;
extern NSString * const khfAcceptLanguage;
extern NSString * const khfAcceptLocale;
extern NSString * const khvLanguage;
extern NSString * const khvLocale;

#pragma mark Endpoints
extern NSString * const kepLogin;
extern NSString * const kepLogout;
extern NSString * const kepRegister;
extern NSString * const kepRegisterUsername;
extern NSString * const kepCaptchaGet;
extern NSString * const kepCaptchaSolve;
extern NSString * const kepBlob;
extern NSString * const kepChatMedia;
extern NSString * const kepPhoneVerify;
extern NSString * const kepDeviceToken;
extern NSString * const kepAllUpdates;
extern NSString * const kepConvoAuth;
extern NSString * const kepConversations;
extern NSString * const kepConvoClear;
extern NSString * const kepConvoPostMessages;
extern NSString * const kepFindFriends;
extern NSString * const kepFriendSearch;
extern NSString * const kepUserExists;
extern NSString * const kepFriends;
extern NSString * const kepFriendHide;
extern NSString * const kepUpdateSnaps;
extern NSString * const kepSharedDescription;
extern NSString * const kepUpdateStories;
extern NSString * const kepUpdateUser;
extern NSString * const kepUpload;
extern NSString * const kepRetrySend;
extern NSString * const kepSend;
extern NSString * const kepTyping;
extern NSString * const kepPostStory;
extern NSString * const kepDeleteStory;
extern NSString * const kepUpdateStories;
extern NSString * const kepBestFriends;
extern NSString * const kepSetBestCount;
extern NSString * const kepClearFeed;
extern NSString * const kepSettings;
extern NSString * const kepFeatures;
extern NSString * const kepSnaptag;

extern NSString * const kepGetStoryBlob;
extern NSString * const kepGetStoryThumb;


