//
//  SKClient+Friends.m
//  SnapchatKit
//
//  Created by Tanner on 5/26/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient+Friends.h"
#import "SKRequest.h"
#import "SKUser.h"
#import "SKFoundFriend.h"

#import "NSDictionary+SnapchatKit.h"
#import "NSArray+SnapchatKit.h"

@implementation SKClient (Friends)

- (void)handleResponse:(id)object error:(NSError *)error completion:(ResponseBlock)completion {
    NSDictionary *json = object;
    if (error) {
        completion(nil, error);
    } else if ([json[@"logged"] boolValue]) {
        SKUser *newFriend = [[SKUser alloc] initWithDictionary:json[@"object"]];
        [self.currentSession.friends addObject:newFriend];
        completion(newFriend, nil);
    } else if (json[@"message"]) {
        completion(nil, [SKRequest errorWithMessage:json[@"message"] code:1]);
    }
}

- (void)addFriend:(NSString *)username completion:(ResponseBlock)completion {
    NSParameterAssert(username);
    NSDictionary *query = @{@"action": @"add",
                            @"friend": username,
                            @"username": self.currentSession.username,
                            @"added_by": @"ADDED_BY_USERNAME"};
    [self postTo:kepFriends query:query callback:^(NSDictionary *json, NSError *error) {
        [self handleResponse:json error:error completion:completion];
    }];
}

- (void)addFriendBack:(NSString *)username completion:(ResponseBlock)completion {
    NSParameterAssert(username);
    NSDictionary *query = @{@"action": @"add",
                            @"friend": username,
                            @"username": self.currentSession.username,
                            @"added_by": @"ADDED_BY_ADDED_ME_BACK"};
    [self postTo:kepFriends query:query callback:^(NSDictionary *json, NSError *error) {
        [self handleResponse:json error:error completion:completion];
    }];
}

- (void)unfriend:(NSString *)friend completion:(ResponseBlock)completion {
    NSParameterAssert(friend);
    NSDictionary *query = @{@"action": @"delete",
                            @"friend": friend,
                            @"username": self.currentSession.username};
    [self postTo:kepFriends query:query callback:^(NSDictionary *json, NSError *error) {
        [self handleResponse:json error:error completion:^(SKUser *oldFriend, NSError *error) {
            [self.currentSession.friends removeObject:oldFriend];
            completion(oldFriend, error);
        }];
    }];
}

- (void)addFriends:(NSArray *)toAdd removeFriends:(NSArray *)toUnfriend completion:(BooleanBlock)completion {
    NSParameterAssert(toAdd || toUnfriend);
    if (!toAdd) toAdd = @[];
    if (!toUnfriend) toUnfriend = @[];
    
    NSDictionary *query = @{@"username": self.currentSession.username,
                            @"action": @"multiadddelete",
                            @"friend": @{@"friendsToAdd": toAdd,
                                         @"friendsToDelete": toUnfriend}.JSONString};
    [self postTo:kepFriends query:query callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            BOOL success = [json[@"message"] isEqualToString:@"success"];
            completion(success, nil);
        } else {
            completion(NO, error);
        }
    }];
}

- (void)bestFriendsOfUsers:(NSArray *)usernames completion:(DictionaryBlock)completion {
    NSParameterAssert(usernames);
    NSDictionary *query = @{@"friend_usernames": usernames.JSONString,
                            @"username": self.currentSession.username};
    [self postTo:kepBestFriends query:query callback:completion];
}

- (void)findFriends:(NSDictionary *)friends completion:(ArrayBlock)completion {
    NSParameterAssert(friends.allKeys.count); NSParameterAssert(completion);
    if (self.currentSession.shouldTextToVerifyNumber || self.currentSession.shouldCallToVerifyNumber)
        completion(nil, [SKRequest errorWithMessage:@"You need to verify your phone number first." code:1]);
    
//    NSArray *findRequests = [friends split:30];
    
    // The people over at SnAPI say it only takes up to 30 numbers at a time,
    // but my phone sent way more than 30 at once.
//    for (NSDictionary *find in findRequests) {
        NSDictionary *query = @{@"username": self.username,
                                @"countryCode": self.currentSession.countryCode,
                                @"numbers": friends.JSONString};
        [self postTo:kepFindFriends query:query callback:^(NSDictionary *json, NSError *error) {
            if (!error) {
                NSArray *contacts = json[@"results"];
                NSMutableArray *foundFriends = [NSMutableArray array];
                for (NSDictionary *f in contacts)
                    [foundFriends addObject:[[SKFoundFriend alloc] initWithDictionary:f]];
                completion(foundFriends, nil);
            } else {
                completion(nil, error);
            }
        }];
//    }
}

- (void)searchFriend:(NSString *)query completion:(ResponseBlock)completion {
    NSParameterAssert(query.length); NSParameterAssert(completion);
    [self postTo:kepFriendSearch query:@{@"query": query, @"username": self.username} callback:completion];
}

- (void)userExists:(NSString *)username completion:(BooleanBlock)completion {
    NSParameterAssert(username); NSParameterAssert(completion);
    
    [self postTo:kepUserExists query:@{@"request_username": username, @"username": self.username} callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            BOOL exists = [json[@"exists"] boolValue];
            completion(exists, nil);
        } else {
            completion(NO, error);
        }
    }];
}

- (void)updateDisplayNameForUser:(NSString *)friend newName:(NSString *)displayName completion:(ErrorBlock)completion {
    NSParameterAssert(displayName.length); NSParameterAssert(friend.length);
    
    NSDictionary *query = @{@"action": @"display",
                            @"display": displayName,
                            @"friend": friend,
                            @"friend_id": @"",
                            @"username": self.username};
    [self postTo:kepFriends query:query callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            SKUser *updated = [[SKUser alloc] initWithDictionary:json[@"object"]];
            [self.currentSession.friends removeObject:updated];
            [self.currentSession.friends addObject:updated];
        }
        completion(error);
    }];
}

- (void)blockUser:(NSString *)username completion:(ErrorBlock)completion {
    [self setUserBlocked:YES user:username completion:completion];
}

- (void)unblockUser:(NSString *)username completion:(ErrorBlock)completion {
    [self setUserBlocked:NO user:username completion:completion];
}

- (void)setUserBlocked:(BOOL)blocked user:(NSString *)username completion:(ErrorBlock)completion {
    NSParameterAssert(username);
    
    NSDictionary *query = @{@"action": blocked ? @"block" : @"unblock",
                            @"friend": username,
                            @"username": self.username};
    [self postTo:kepFriends query:query callback:^(NSDictionary *json, NSError *error) {
        completion(error);
    }];
}

@end
