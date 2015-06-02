//
//  SKClient+Friends.m
//  SnapchatKit
//
//  Created by Tanner on 5/26/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient+Friends.h"
#import "SKRequest.h"

@implementation SKClient (Friends)

- (void)addFriend:(NSString *)friend completion:(DictionaryBlock)completion {
    NSParameterAssert(friend);
    NSDictionary *query = @{@"action": @"add",
                            @"friend": friend,
                            @"username": self.currentSession.username,
                            @"added_by": @"ADDED_BY_USERNAME"};
    [SKRequest postTo:kepFriends query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:error data:data response:response completion:completion];
        });
    }];
}

- (void)unfriend:(NSString *)friend completion:(DictionaryBlock)completion {
    NSParameterAssert(friend);
    NSDictionary *query = @{@"action": @"delete",
                            @"friend": friend,
                            @"username": self.currentSession.username};
    [SKRequest postTo:kepFriends query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:error data:data response:response completion:completion];
        });
    }];
}

- (void)bestFriendsOfUsers:(NSArray *)usernames completion:(DictionaryBlock)completion {
    NSParameterAssert(usernames);
    NSDictionary *query = @{@"friend_usernames": usernames,
                            @"username": self.currentSession.username,
                            @"features_map": @{}};
    [SKRequest postTo:kepBestFriends query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:error data:data response:response completion:completion];
        });
    }];
}

@end
