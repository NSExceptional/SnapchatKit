//
//  SKSession.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSession.h"
#import "SKStoryCollection.h"
#import "SKUserStory.h"
#import "SKUser.h"
#import "SKAddedFriend.h"
#import "SKConversation.h"

@implementation SKSession

- (id)init {
    NSAssert(nil, false);
    return nil;
}

+ (instancetype)sessionWithJSONResponse:(NSDictionary *)json {
    return [[SKSession alloc] initWithDictionary:json];
}

- (id)initWithDictionary:(NSDictionary *)json {
    
    NSDictionary *storiesResponse = json[@"stories_response"];
    NSDictionary *friendsResponse = json[@"friends_response"];
    NSDictionary *identity        = json[@"identity_check_response"];
    
    NSArray *friendStories = storiesResponse[@"friend_stories"];
    NSArray *myStories     = storiesResponse[@"my_stories"];
    //NSArray *groupStories  = storiesResponse[@"my_group_stories"];
    
    NSArray *friends       = friendsResponse[@"friends"];
    NSArray *added         = friendsResponse[@"added_friends"];
    NSArray *conversations = json[@"conversations_response"];
    
    
    self = [super initWithDictionary:json];
    if (self) {
        _backgroundFetchSecret = json[@"background_fetch_secret_key"];
        _bestFriendUsernames   = friendsResponse[@"bests"];
        
        _storiesDelta      = [storiesResponse[@"friend_stories_delta"] boolValue];
        _discoverSupported = ![json[@"discover"][@"compatibility"] isEqualToString:@"device_not_supported"];
        _emailVerified     = [identity[@"is_email_verified"] boolValue];
        
        // Friends
        NSMutableArray *temp = [NSMutableArray new];
        for (NSDictionary *friend in friends)
            [temp addObject:[[SKUser alloc] initWithDictionary:friend]];
        _friends = temp;
        
        // Added friends
        temp = [NSMutableArray new];
        for (NSDictionary *addedFriend in added)
            [temp addObject:[[SKAddedFriend alloc] initWithDictionary:addedFriend]];
        _addedFriends = temp;
        
        // Conversations
        temp = [NSMutableArray new];
        for (NSDictionary *convo in conversations)
            [temp addObject:[[SKConversation alloc] initWithDictionary:convo]];
        _conversations = temp;
        
        // Story collections
        temp = [NSMutableArray new];
        for (NSDictionary *collection in friendStories)
            [temp addObject:[[SKStoryCollection alloc] initWithDictionary:collection]];
        _stories = temp;
        
        // User stories
        temp = [NSMutableArray new];
        for (NSDictionary *story in myStories)
            [temp addObject:[[SKUserStory alloc] initWithDictionary:story]];
        _userStories = temp;
        
        // Group stories?
        _groupStories = @[];
    }
    
    [self.knownJSONKeys addObjectsFromArray:@[@"stories_response", @"friends_response", @"identity_check_response", @"background_fetch_secret_key", @"discover"]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ stories delta=%hhd, discover=%hhd, email verified=%hhd, friends=%lu, added=%lu, stories=%lu, user stories=%lu>",
            NSStringFromClass(self.class), self.storiesDelta, self.discoverSupported, self.emailVerified,
            (unsigned long)self.friends.count, self.addedFriends.count, (unsigned long)self.stories.count,
            (unsigned long)self.userStories.count];
}

//- (id)initWithCoder:(NSCoder *)aDecoder {
//    
//}
//
//- (void)encodeWithCoder:(NSCoder *)aCoder {
//    
//}

@end
