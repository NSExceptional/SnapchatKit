//
//  SKSession.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKThing.h"

@class SKMessage, SKConversation;

typedef NS_ENUM(NSUInteger, SKStoryPrivacy)
{
    SKStoryPrivacyEveryone = 1,
    SKStoryPrivacyFriends,
    SKStoryPrivacyCustom
};

extern SKStoryPrivacy SKStoryPrivacyFromString(NSString *storyPrivacyString);


@interface SKSession : SKThing //<NSCoding>

+ (instancetype)sessionWithJSONResponse:(NSDictionary *)json;

/** Array unread SKSnap and SKMessage objects in _conversations. */
- (NSArray *)unread;
/** Returns the SKConversation associated with the given username, or nil if it hasn't been loaded or does not exist (or if username == self.username). */
- (SKConversation *)conversationWithOtherUser:(NSString *)username;

/** Not sure what this is for. Might be "new stories since you last checked". */
@property (nonatomic, readonly) BOOL storiesDelta;
@property (nonatomic, readonly) BOOL discoverSupported;
@property (nonatomic, readonly) BOOL emailVerified;

@property (nonatomic, readonly) NSString *backgroundFetchSecret;

#pragma mark User data

/** Array of SKUser objects. */
@property (nonatomic, readonly) NSMutableOrderedSet *friends;
/** Array of SKAddedFriend objects who may or may not be your friend. */
@property (nonatomic, readonly) NSMutableOrderedSet *addedFriends;
/** Array of username strings. */
@property (nonatomic, readonly) NSMutableOrderedSet *bestFriendUsernames;

/** Array of username strings of users who have added you but not been added back by you. */
@property (nonatomic, readonly) NSMutableOrderedSet *pendingRequests;

/** Array of SKConversation objects. */
@property (nonatomic, readonly) NSMutableOrderedSet *conversations;
/** Array of SKStoryCollectionx objects of friends' stories. */
@property (nonatomic, readonly) NSMutableOrderedSet *stories;
/** Array of SKUserStory objects of the user's stories. */
@property (nonatomic, readonly) NSMutableOrderedSet *userStories;
/** Array of SKStory objects of the user's group stories. Empty so far. */
@property (nonatomic, readonly) NSMutableOrderedSet *groupStories;

#pragma mark Cash information
@property (nonatomic, readonly) BOOL         canUseCash;
@property (nonatomic, readonly) BOOL         isCashActive;
/** Seems to be your username. */
@property (nonatomic, readonly) NSString     *cashCustomerIdentifier;
/** i.e. "SQUARE" */
@property (nonatomic, readonly) NSString     *cashProvider;
/** Keys: "snapcash_new_tos_accepted", "snapcash_tos_v2_accepted", "square_tos_accepted" */
@property (nonatomic, readonly) NSDictionary *cashClientProperties;

#pragma mark Basic user information
@property (nonatomic, readonly) NSString     *username;
@property (nonatomic, readonly) NSString     *email;
@property (nonatomic, readonly) NSString     *mobileNumber;
@property (nonatomic, readonly) NSUInteger   recieved;
@property (nonatomic, readonly) NSUInteger   sent;
@property (nonatomic, readonly) NSUInteger   score;
/** Array of usernames. */
@property (nonatomic, readonly) NSArray      *recents;
/** Probably an array of usernames. */
@property (nonatomic, readonly) NSArray      *requests;


#pragma mark Account information
@property (nonatomic, readonly) NSDate       *addedFriendsTimestamp;
@property (nonatomic, readonly) NSString     *authToken;
@property (nonatomic, readonly) BOOL         canSeeMatureContent;
/** i.e. "US" */
@property (nonatomic, readonly) NSString     *countryCode;
@property (nonatomic, readonly) NSDate       *lastTimestamp;
@property (nonatomic, readonly) NSString     *devicetoken;
@property (nonatomic, readonly) BOOL         canSaveStoryToGallery;
/** Unknown. */
@property (nonatomic, readonly) BOOL         canVideoTranscodingAndroid;
@property (nonatomic, readonly) BOOL         imageCaption;
/** Unknown. */
@property (nonatomic, readonly) BOOL         isTwoFAEnabled;
@property (nonatomic, readonly) NSDate       *lastAddressBookUpdateDate;
@property (nonatomic, readonly) NSDate       *lastReplayedSnapDate;
/** Unknown. */
@property (nonatomic, readonly) BOOL         logged;
@property (nonatomic, readonly) NSString     *mobileVerificationKey;
@property (nonatomic, readonly) BOOL         canUploadRawThumbnail;
/** Array of strings. */
@property (nonatomic, readonly) NSArray      *seenTooltips;
@property (nonatomic, readonly) BOOL         shouldCallToVerifyNumber;
@property (nonatomic, readonly) BOOL         shouldTextToVerifyNumber;
/** YES if everyone can send you snaps, NO if only friends can. */
/** Unknown. */
@property (nonatomic, readonly) NSString     *snapchatPhoneNumber;
@property (nonatomic, readonly) NSDictionary *studySettings;
/** Unknown. */
@property (nonatomic, readonly) NSDictionary *targeting;
@property (nonatomic, readonly) NSString     *userIdentifier;
@property (nonatomic, readonly) BOOL         enableVideoFilters;
@property (nonatomic, readonly) NSString     *QRPath;


#pragma mark User preferences
@property (nonatomic, readonly) BOOL           enableNotificationSounds;
@property (nonatomic, readonly) NSUInteger     numberOfBestFriends;
@property (nonatomic, readonly) SKStoryPrivacy storyPrivacy;
@property (nonatomic, readonly) BOOL           isSearchableByPhoneNumber;
@property (nonatomic, readonly) BOOL           privacyEveryone;

#pragma mark Features
@property (nonatomic, readonly) BOOL enableFrontFacingFlash;
@property (nonatomic, readonly) BOOL enablePowerSaveMode;
@property (nonatomic, readonly) BOOL enableReplaySnaps;
@property (nonatomic, readonly) BOOL enableSmartFilters;
@property (nonatomic, readonly) BOOL enableSpecialText;
@property (nonatomic, readonly) BOOL enableSwipeCashMode;
@property (nonatomic, readonly) BOOL enableVisualFilters;

@end
