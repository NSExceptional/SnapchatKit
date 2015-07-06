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
#define kScreenWidth (720)
#define kScreenHeight (1280)
#endif

#define kDebugJSON YES
#define kVerboseLog YES

#define SKTempDirectory() [NSTemporaryDirectory() stringByAppendingPathComponent:@"SnapchatKit-tmp"]

typedef void (^RequestBlock)(NSData *data, NSURLResponse *response, NSError *error);
typedef void (^BooleanBlock)(BOOL success, NSError *error);
typedef void (^DataBlock)(NSData *data, NSError *error);
typedef void (^StringBlock)(NSString *string, NSError *error);
typedef void (^DictionaryBlock)(NSDictionary *dict, NSError *error);
typedef void (^ArrayBlock)(NSArray *collection, NSError *error);
typedef void (^CollectionResponseBlock)(NSArray *success, NSArray *failed, NSArray *errors);
typedef void (^ResponseBlock)(id object, NSError *error);
typedef void (^ErrorBlock)(NSError *error);
typedef void (^VoidBlock)();

extern void SKLog(NSString *format, ...);

typedef NS_ENUM(NSUInteger, SKSnapPrivacy)
{
    SKSnapPrivacyEveryone,
    SKSnapPrivacyFriends
};

typedef NS_ENUM(NSUInteger, SKStoryPrivacy)
{
    SKStoryPrivacyFriends,
    SKStoryPrivacyEveryone,
    SKStoryPrivacyCustom
};

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

extern SKAddSource SKAddSourceFromString(NSString *addSourceString);
extern NSString * SKStringFromAddSource(SKAddSource addSource);
extern NSString * SKStringFromMediaKind(SKMediaKind mediaKind);
extern NSString * SKStringFromStoryPrivacy(SKStoryPrivacy);

extern BOOL SKMediaKindIsImage(SKMediaKind mediaKind);
extern BOOL SKMediaKindIsVideo(SKMediaKind mediaKind);

/** Before updating this value, confirm that the library requests everything in the same way as the app. */
extern NSString * const kUserAgent;
/** The user agent specific to making the attestation request. */
extern NSString * const kUserAgentForAttestation;
/** The API URL. iOS uses the /bq endpoint, Android clients use the /ph endpoint. */
extern NSString * const kURL;
/** An alternate base URL for sending certain POST requests. */
extern NSString * const kEventsURL;
/** The API secret used to create access tokens. */
extern NSString * const kSecret;
/** Used when no session is available. */
extern NSString * const kStaticToken;
/** Used to encrypt and decrypt media. */
extern NSString * const kBlobEncryptionKey;
/** Used to create the token for each request. */
extern NSString * const kHashPattern;
/** Used to separate form fields when sending snaps. */
extern NSString * const kBoundary;
/** Used to generate attestation. Base 64 encoded, and version specific. Current is 9.10.0.0. */
extern NSString * const kAPKDigest;
/** The sha256 digest of the certificate used to sign the Snapchat APK, base 64 encoded. It should never change. */
extern NSString * const kAPKCertificateDigest;
/** Google Play Services version used to make the attestation request. */
extern NSString * const kGMSVersion;

/** Authentication token sent to verify requests with the server to prevent abuse. */
extern NSString * const kAttestationAuth;
/** SnapKeep™ attestation request URL. Special thanks to Harry! */
extern NSString * const kAttestationURLSK;
/** Casper™ attestation request URL. Special thanks to Liam! */
extern NSString * const kAttestationURLCasper;
/** This one does not work. */
extern NSString * const kAPKDigest9_10;
/** This one works for some reason. */
extern NSString * const kAPKDigest9_8;

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
extern NSString * const kepConversation;
extern NSString * const kepConvoClear;
extern NSString * const kepConvoPostMessages;
extern NSString * const kepFindFriends;
extern NSString * const kepFriendSearch;
extern NSString * const kepUserExists;
extern NSString * const kepFriends;
extern NSString * const kepFindNearby;
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
extern NSString * const kepPostStoryRetry;
extern NSString * const kepDeleteStory;
extern NSString * const kepUpdateStories;
extern NSString * const kepBestFriends;
extern NSString * const kepSetBestCount;
extern NSString * const kepClearFeed;
extern NSString * const kepSettings;
extern NSString * const kepFeatures;
extern NSString * const kepSnaptag;
extern NSString * const kepCashEligible;
extern NSString * const kepCashGenerateToken;
extern NSString * const kepLocationData;
extern NSString * const kepDownloadSnaptagAvatar;
extern NSString * const kepUploadSnaptagAvatar;

extern NSString * const kepGetStoryBlob;
extern NSString * const kepGetStoryThumb;

#pragma mark Feature settings
extern NSString * const SKFeatureFrontFacingFlash;
extern NSString * const SKFeatureReplaySnaps;
extern NSString * const SKFeatureSmartFilters;
extern NSString * const SKFeatureVisualFilters;
