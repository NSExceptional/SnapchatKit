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

#define NSNSString __unsafe_unretained NSString
#define NSNSURL __unsafe_unretained NSURL
#define SK_NAMESPACE(name, vals) extern const struct name vals name
#define SK_NAMESPACE_IMP(name) const struct name name =


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
    SKAddSourceAddedBack
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

typedef NS_ENUM(NSInteger, SKFriendStatus) {
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

extern NSString * const SKNoConversationExistsYet;
extern NSString * const SKTemporaryLoginFailure;

/** Various attestation related strings. */
SK_NAMESPACE(SKAttestation, {
    /** The user agent specific to making the attestation request. */
    NSNSString *userAgent;
    /** The sha256 digest of the certificate used to sign the Snapchat APK, base 64 encoded. It should never change. */
    NSNSString *certificateDigest;
    /** Google Play Services version used to make the attestation request. */
    NSInteger  GMSVersion;
    /** The URL used to get the bytecode needed to generate droidguard and attestation. */
    NSNSString *protobufBytecodeURL;
    NSNSString *protobufPOSTURL;
    NSNSString *attestationURL;
    NSNSString *digest9_8;
    NSNSString *digest9_9;
    NSNSString *digest9_10;
    NSNSString *digest9_11;
    NSNSString *digest9_12_0_1;
    NSNSString *digest9_12_1;
    NSNSString *digest9_12_2;
    NSNSString *digest9_13;
    NSNSString *digest9_14;
    NSNSString *digest9_14_2;
    
});

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
    NSNSString *frontFacingFlash;
    NSNSString *replaySnaps;
    NSNSString *smartFilters;
    NSNSString *visualFilters;
    NSNSString *powerSaveMode;
    NSNSString *specialText;
    NSNSString *swipeCashMode;
    NSNSString *travelMode;
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
