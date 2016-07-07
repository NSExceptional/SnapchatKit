//
//  SKClient+Friends.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/26/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient+Friends.h"
#import "SKRequest.h"
#import "SKUser.h"
#import "SKFoundFriend.h"
#import "SKNearbyUser.h"

#import "SnapchatKit-Constants.h"
#import <CoreLocation/CLLocation.h>


@implementation SKClient (Friends)

- (void)handleResponse:(TBResponseParser *)parser completion:(ResponseBlock)completion {
    if (parser.error) {
        completion(nil, parser.error);
    }
    else if ([parser.JSON[@"logged"] boolValue]) {
        SKUser *newFriend = [[SKUser alloc] initWithDictionary:parser.JSON[@"object"]];
        [self.currentSession.friends addObject:newFriend];
        completion(newFriend, nil);
    }
    else if (parser.JSON[@"message"]) {
        completion(nil, [TBResponseParser error:parser.JSON[@"message"] domain:@"SnapchatKit" code:parser.response.statusCode]);
    }
}

- (void)addFriend:(NSString *)username completion:(ResponseBlock)completion {
    NSParameterAssert(username);
    NSDictionary *params = @{@"action": @"add",
                             @"friend": username,
                             @"username": self.currentSession.username,
                             @"added_by": @"ADDED_BY_USERNAME"};
    [self postWith:params to:SKEPFriends.friend callback:^(TBResponseParser *parser) {
        [self handleResponse:parser completion:completion];
    }];
}

- (void)addFriendBack:(NSString *)username completion:(ResponseBlock)completion {
    NSParameterAssert(username);
    NSDictionary *params = @{@"action": @"add",
                             @"friend": username,
                             @"username": self.currentSession.username,
                             @"added_by": @"ADDED_BY_ADDED_ME_BACK"};
    [self postWith:params to:SKEPFriends.friend callback:^(TBResponseParser *parser) {
        [self handleResponse:parser completion:completion];
    }];
}

- (void)unfriend:(NSString *)friend completion:(ResponseBlock)completion {
    NSParameterAssert(friend);
    NSDictionary *params = @{@"action": @"delete",
                             @"friend": friend,
                             @"username": self.currentSession.username};
    [self postWith:params to:SKEPFriends.friend callback:^(TBResponseParser *parser) {
        [self handleResponse:parser completion:^(SKUser *oldFriend, NSError *error) {
            [self.currentSession.friends removeObject:oldFriend];
            TBRunBlockP(completion, oldFriend, error);
        }];
    }];
}

- (void)addFriends:(NSArray *)toAdd removeFriends:(NSArray *)toUnfriend completion:(ErrorBlock)completion {
    NSParameterAssert(toAdd || toUnfriend);
    if (!toAdd) toAdd = @[];
    if (!toUnfriend) toUnfriend = @[];
    
    NSDictionary *params = @{@"username": self.currentSession.username,
                             @"action": @"multiadddelete",
                             @"friend": @{@"friendsToAdd": toAdd,
                                          @"friendsToDelete": toUnfriend}.JSONString,
                             @"added_by": @"ADDED_BY_USERNAME"};
    [self postWith:params to:SKEPFriends.friend callback:^(TBResponseParser *parser) {
        //        BOOL success = [parser.JSON[@"message"] isEqualToString:@"success"];
        TBRunBlockP(completion, parser.error);
    }];
}

- (void)bestFriendsOfUsers:(NSArray *)usernames completion:(DictionaryBlock)completion {
    NSParameterAssert(usernames);
    NSDictionary *params = @{@"friend_usernames": usernames.JSONString,
                             @"friend_user_ids": @"", // TODO: user ids
                             @"username": self.currentSession.username};
    [self postWith:params to:SKEPFriends.bests callback:^(TBResponseParser *parser) {
        TBRunBlockP(completion, parser.JSON, parser.error);
    }];
}

- (void)findFriends:(NSDictionary *)friends completion:(ArrayBlock)completion {
    NSParameterAssert(friends.allKeys.count); NSParameterAssert(completion);
    if (self.currentSession.shouldTextToVerifyNumber || self.currentSession.shouldCallToVerifyNumber)
        completion(nil, [SKRequest errorWithMessage:@"You need to verify your phone number first." code:1]);
    
    //    NSArray *findRequests = [friends split:30];
    
    // The people over at SnAPI say it only takes up to 30 numbers at a time,
    // but my phone sent way more than 30 at once.
    //    for (NSDictionary *find in findRequests) {
    NSDictionary *params = @{@"username": self.username,
                             @"countryCode": self.currentSession.countryCode,
                             @"numbers": friends.JSONString};
    [self postWith:params to:SKEPFriends.find callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            completion([SKThing transformJSONArray:parser.JSON[@"results"] toModelsOfClass:[SKFoundFriend class]], nil);
        } else {
            completion(nil, parser.error);
        }
    }];
}

- (void)findFriendsNear:(CLLocation *)location accuracy:(CGFloat)meters pollDurationSoFar:(NSUInteger)milliseconds completion:(ArrayBlock)completion {
    NSParameterAssert(location); NSParameterAssert(completion);
    if (meters <= 0) {
        meters = 10;
    }
    
    NSDictionary *params = @{@"username": self.username,
                             @"accuracyMeters": @(meters),
                             @"action": @"update",
                             @"lat": @(location.coordinate.latitude),
                             @"long": @(location.coordinate.longitude),
                             @"totalPollingDurationMillis": @(milliseconds)};
    [self postWith:params to:SKEPFriends.findNearby callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            completion([SKThing transformJSONArray:parser.JSON[@"nearby_snapchatters"] toModelsOfClass:[SKNearbyUser class]], nil);
        } else {
            completion(nil, parser.error);
        }
    }];
}

- (void)searchFriend:(NSString *)query completion:(ResponseBlock)completion {
    NSParameterAssert(query.length); NSParameterAssert(completion);
    [self postWith:@{@"query": query, @"username": self.username} to:SKEPFriends.search callback:^(TBResponseParser *parser) {
        completion(parser.JSON ?: parser.data, parser.error);
    }];
}

- (void)userExists:(NSString *)username completion:(BooleanBlock)completion {
    NSParameterAssert(username); NSParameterAssert(completion);
    
    NSDictionary *params = @{@"request_username": username,
                             @"username": self.username};
    [self postWith:params to:SKEPFriends.exists callback:^(TBResponseParser *parser) {
        completion([parser.JSON[@"exists"] boolValue], parser.error);
    }];
}

- (void)updateDisplayNameForUser:(NSString *)friend newName:(NSString *)displayName completion:(ErrorBlock)completion {
    NSParameterAssert(displayName.length); NSParameterAssert(friend.length);
    
    NSDictionary *params = @{@"action": @"display",
                             @"display": displayName,
                             @"friend": friend,
                             @"friend_id": @"",
                             @"username": self.username};
    [self postWith:params to:SKEPFriends.friend callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            SKUser *updated = [[SKUser alloc] initWithDictionary:parser.JSON[@"object"]];
            [self.currentSession.friends removeObject:updated];
            [self.currentSession.friends addObject:updated];
        }
        completion(parser.error);
    }];
}

- (void)blockUser:(NSString *)username reason:(SKBlockReason)reason completion:(ErrorBlock)completion {
    [self setUserBlocked:YES user:username reason:reason completion:completion];
}

- (void)getSuggestedFriends:(ArrayBlock)completion {
    NSDictionary *params = @{@"action": @"list",
                             @"username": self.username};
    [self postWith:params to:SKEPMisc.suggestFriend callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            completion([SKThing transformJSONArray:parser.JSON[@"suggested_friend_results"] toModelsOfClass:nil], nil);
        } else {
            completion(nil, parser.error);
        }
    }];
}

- (void)seenSuggestedFriends:(NSArray *)usernames seen:(BOOL)seen completion:(ErrorBlock)completion {
    if (!usernames.count) usernames = @[];
    
    NSDictionary *params = @{@"action": @"update",
                             @"seen": @(seen),
                             @"seen_suggested_friend_list": usernames.JSONString,
                             @"username": self.username};
    [self postWith:params to:SKEPMisc.suggestFriend callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            if ([parser.JSON[@"logged"] boolValue]) {
                completion(nil);
            } else {
                completion([TBResponseParser error:parser.JSON[@"message"] domain:@"SnapchatKit" code:parser.response.statusCode]);
            }
        } else {
            completion(parser.error);
        }
    }];
}

- (void)unblockUser:(NSString *)username completion:(ErrorBlock)completion {
    [self setUserBlocked:NO user:username reason:-1 completion:completion];
}

- (void)setUserBlocked:(BOOL)blocked user:(NSString *)username reason:(SKBlockReason)reason completion:(ErrorBlock)completion {
    NSParameterAssert(username); NSParameterAssert(reason || !blocked);
    NSMutableDictionary *params = @{@"action": blocked ? @"block" : @"unblock",
                                    @"friend": username,
                                    @"friend_id": [self.currentSession userWithUsername:username].userIdentifier,
                                    @"username": self.username}.mutableCopy;
    if (blocked) params[@"block_reason_id"] = @(reason);
    [self postWith:params to:SKEPFriends.friend callback:^(TBResponseParser *parser) {
        completion(parser.error);
    }];
}


@end
