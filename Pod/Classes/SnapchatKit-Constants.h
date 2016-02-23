//
//  SnapchatKit-Constants.h
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
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

#define kDebugJSON 1
#define kVerboseLog 1

#define SKTempDirectory() [NSTemporaryDirectory() stringByAppendingPathComponent:@"SnapchatKit-tmp"]

#define NSNSString __unsafe_unretained NSString
#define NSNSURL __unsafe_unretained NSURL
#define SK_NAMESPACE(name, vals) extern const struct name vals name
#define SK_NAMESPACE_IMP(name) const struct name name =

#define SKRunBlock(block) if ( block ) block()
#define SKRunBlockP(block, ...) if ( block ) block( __VA_ARGS__ )


typedef void (^RequestBlock)(NSData *data, NSURLResponse *response, NSError *error);
typedef void (^BooleanBlock)(BOOL success, NSError *error);
typedef void (^DataBlock)(NSData *data, NSError *error);
typedef void (^StringBlock)(NSString *string, NSError *error);
typedef void (^DictionaryBlock)(NSDictionary *dict, NSError *error);
typedef void (^ArrayBlock)(NSArray *collection, NSError *error);
typedef void (^CollectionResponseBlock)(NSArray *success, NSArray *failed, NSArray *errors);
typedef void (^ResponseBlock)(id object, NSError *error);
typedef void (^MiddleManBlock)(id object, NSError *error, NSURLResponse *response);
typedef void (^ErrorBlock)(NSError *error);
typedef void (^VoidBlock)();

extern void SKLog(NSString *format, ...);

typedef NS_ENUM(NSUInteger, SKSnapPrivacy) {
    SKSnapPrivacyEveryone,
    SKSnapPrivacyFriends
};

typedef NS_ENUM(NSUInteger, SKStoryPrivacy) {
    SKStoryPrivacyFriends,
    SKStoryPrivacyEveryone,
    SKStoryPrivacyCustom
};

typedef NS_ENUM(NSInteger, SKAddSource) {
    SKAddSourcePhonebook = 1,
    SKAddSourceUsername,
    SKAddSourceAddedBack,
    SKAddSourceQRCode,
    SKAddSourceNearby
};

typedef NS_ENUM(NSInteger, SKMediaKind) {
    SKMediaKindImage,
    SKMediaKindVideo,
    SKMediaKindSilentVideo,
    SKMediaKindFriendRequest,
    SKMediaKindStrangerImage,
    SKMediaKindStrangerVideo,
    SKMediaKindStrangerSilentVideo
};

typedef NS_ENUM(NSInteger, SKSnapStatus) {
    SKSnapStatusNone       = -1,
    SKSnapStatusSent       = 0,
    SKSnapStatusDelivered  = 1,
    SKSnapStatusOpened     = 2,
    SKSnapStatusScreenshot = 3
};

typedef NS_ENUM(NSUInteger, SKFriendStatus)
{
    SKFriendStatusMutual,
    SKFriendStatusPending,
    SKFriendStatusBlocked,
    SKFriendStatusDeleted,
    SKFriendStatusFollower = 6
};

typedef NS_ENUM(NSUInteger, SKBlockReason)
{
    SKBlockReasonOther,
    SKBlockReasonInappropriateSnaps,
    SKBlockReasonHarassingMe,
    SKBlockReasonAnnoying,
    SKBlockReasonIDKThem
};

typedef NS_ENUM(NSUInteger, SKAvatarSize)
{
    SKAvatarSizeThumbnail,
    SKAvatarSizeMedium,
    SKAvatarSizeLarge
};



extern SKAddSource SKAddSourceFromString(NSString *);
extern NSString * SKStringFromAddSource(SKAddSource);
extern NSString * SKStringFromMediaKind(SKMediaKind);
extern NSString * SKStringFromStoryPrivacy(SKStoryPrivacy);
extern NSString * SKStringFromBlockReason(SKBlockReason);
extern NSString * SKStringFromAvatarSize(SKAvatarSize);

extern BOOL SKMediaKindIsImage(SKMediaKind mediaKind);
extern BOOL SKMediaKindIsVideo(SKMediaKind mediaKind);

extern NSString * const SKNoConversationExistsYet;
extern NSString * const SKTemporaryLoginFailure;

SK_NAMESPACE(SKConsts, {
    /** The API URL. iOS uses the /bq endpoint, Android clients use the /ph endpoint. */
    NSNSString *baseURL;
    /** Before updating this value, confirm that the library requests everything in the same way as the app. */
    NSNSString *userAgent;
    /** An alternate base URL for sending certain POST requests. */
    NSNSString *eventsURL;
    /** The base URL for sending analytics. */
    NSNSString *analyticsURL;
    /** The API secret used to create access tokens. */
    NSNSString *secret;
    /** Used when no session is available. */
    NSNSString *staticToken;
    /** Used to encrypt and decrypt media. */
    NSNSString *blobEncryptionKey;
    /** Used to create the token for each request. */
    NSNSString *hashPattern;
    /** Used to separate form fields when sending snaps. */
    NSNSString *boundary;
    NSNSString *deviceToken1i;
    NSNSString *deviceToken1v;
    NSNSString *snapchatVersion;
});

#pragma mark Header fields / values
SK_NAMESPACE(SKHeaders, {
    NSNSString *timestamp;
    NSNSString *userAgent;
    NSNSString *contentType;
    NSNSString *acceptLanguage;
    NSNSString *acceptLocale;
    NSNSString *clientAuth;
    NSNSString *clientToken;
    NSNSString *clientAuthToken;
    NSNSString *casperAPIKey;
    NSNSString *casperSignature;
    struct {
        NSNSString *language;
        NSNSString *locale;
        NSNSString *droidGuardUA;
        NSNSString *protobuf;
    } values;
});

#pragma mark Feature settings
SK_NAMESPACE(SKFeatureSettings, {
    NSNSString *travelMode;
    NSNSString *barcodeEnabled;
    NSNSString *smartFilters;
    NSNSString *payReplaySnaps;
    NSNSString *lensStoreEnabled;
    NSNSString *visualFilters;
    NSNSString *prefetchLensStore;
    NSNSString *QRCodeEnabled;
    NSNSString *scrambleBestFriends;
});


#pragma mark Endpoints
SK_NAMESPACE(SKEPMisc, {
    NSNSString *ping;
    NSNSString *locationData;
    NSNSString *serverList;
    NSNSString *doublePost;
    NSNSString *reauth;
    NSNSString *suggestFriend;
});

SK_NAMESPACE(SKEPUpdate, {
    NSNSString *all;
    NSNSString *snaps;
    NSNSString *stories;
    NSNSString *user;
    NSNSString *trophies;
    NSNSString *featureSettings;
});

SK_NAMESPACE(SKEPAccount, {
    NSNSString *login;
    NSNSString *logout;
    NSNSString *twoFAPhoneVerify;
    NSNSString *twoFARecoveryCode;
    NSNSString *setBestsCount;
    NSNSString *settings;
    NSNSString *snaptag;
    struct {
        NSNSString *start;
        NSNSString *username;
        NSNSString *getCaptcha;
        NSNSString *solveCaptcha;
        NSNSString *verifyPhone;
        NSNSString *suggestUsername;
    } registration;
    struct {
        NSNSString *set;
        NSNSString *get;
        NSNSString *remove;
        NSNSString *getFriend;
    } avatar;
});

SK_NAMESPACE(SKEPChat, {
    NSNSString *sendMessage;
    NSNSString *conversation;
    NSNSString *conversations;
    NSNSString *authToken;
    NSNSString *clear;
    NSNSString *clearFeed;
    NSNSString *clearConvo;
    NSNSString *typing;
    NSNSString *media;
    NSNSString *uploadMedia;
    NSNSString *shareMedia;
});

SK_NAMESPACE(SKEPDevice, {
    NSNSString *IPRouting;
    NSNSString *IPRoutingError;
    NSNSString *identifier;
    NSNSString *device;
});

SK_NAMESPACE(SKEPDiscover, {
    NSNSString *channels;
    NSNSString *icons;
    NSNSString *snaps;
    NSNSString *intros;
});

SK_NAMESPACE(SKEPFriends, {
    NSNSString *find;
    NSNSString *findNearby;
    NSNSString *bests;
    NSNSString *friend;
    NSNSString *hide;
    NSNSString *search;
    NSNSString *exists;
});

SK_NAMESPACE(SKEPSnaps, {
    NSNSString *loadBlob;
    NSNSString *upload;
    NSNSString *send;
    NSNSString *retry;
});

SK_NAMESPACE(SKEPStories, {
    NSNSString *stories;
    NSNSString *upload;
    NSNSString *blob;
    NSNSString *thumb;
    NSNSString *authBlob;
    NSNSString *authThumb;
    NSNSString *remove;
    NSNSString *post;
    NSNSString *retryPost;
});

SK_NAMESPACE(SKEPCash, {
    NSNSString *checkRecipientEligibility;
    NSNSString *generateAccessToken;
    NSNSString *generateSignature;
    NSNSString *markViewed;
    NSNSString *resetAccount;
    NSNSString *transaction;
    NSNSString *updateTransaction;
    NSNSString *validateTransaction;
});

SK_NAMESPACE(SKEPAndroid, {
    NSNSString *findNearbyFriends;
    NSNSString *changeEmail;
    NSNSString *changePass;
    NSNSString *getPassStrength;
    NSNSString *registerExp;
});


extern NSString * const kepSharedDescription;
