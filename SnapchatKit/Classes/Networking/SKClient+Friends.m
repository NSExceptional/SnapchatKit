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

- (void)bestFriendsOfUsers:(NSArray *)usernames completion:(DictionaryBlock)completion {
    NSParameterAssert(usernames);
    NSDictionary *query = @{@"friend_usernames": usernames,
                            @"username": self.currentSession.username};
    [self postTo:kepBestFriends query:query callback:completion];
}

@end
