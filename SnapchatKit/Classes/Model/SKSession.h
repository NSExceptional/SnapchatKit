//
//  SKSession.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKThing.h"

@interface SKSession : SKThing //<NSCoding>

+ (instancetype)sessionWithJSONResponse:(NSDictionary *)json;

/** Not sure what this is for. Might be "new stories since you last checked". */
@property (nonatomic, readonly) BOOL storiesDelta;
@property (nonatomic, readonly) BOOL discoverSupported;
@property (nonatomic, readonly) BOOL emailVerified;

@property (nonatomic, readonly) NSString *backgroundFetchSecret;

/** Array of SKUser objects. */
@property (nonatomic, readonly) NSArray *friends;
/** Array of SKAddedFriend objects. */
@property (nonatomic, readonly) NSArray *addedFriends;
/** Array of NSString's of usernames. */
@property (nonatomic, readonly) NSArray *bestFriendUsernames;

/** Array of SKConversation objects. */
@property (nonatomic, readonly) NSArray *conversations;
/** Array of SKStoryCollectionx objects of friends' stories. */
@property (nonatomic, readonly) NSArray *stories;
/** Array of SKUserStory objects of the user's stories. */
@property (nonatomic, readonly) NSArray *userStories;
/** Array of SKStory objects of the user's group stories. Empty so far. */
@property (nonatomic, readonly) NSArray *groupStories;


//@property (nonatomic, readonly) 

@end
