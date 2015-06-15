//
//  SKClient+Friends.h
//  SnapchatKit
//
//  Created by Tanner on 5/26/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKClient.h"

@interface SKClient (Friends)

/** The callback takes an SKUser object, which is automatically added to _currentSession.friends. */
- (void)addFriend:(NSString *)username completion:(ResponseBlock)completion;
/** The callback takes an SKUser object, which is automatically added to _currentSession.friends. */
- (void)addFriendBack:(NSString *)username completion:(ResponseBlock)completion;

/** The callback takes an SKUser object, which is automatically removed from _currentSession.friends. */
- (void)unfriend:(NSString *)username completion:(ResponseBlock)completion;

/** Depricated API call. Best friends will be empty. Callback dictionary is in the following format:
 @code
 {
    username = {
        "best_friends" = ();
        score = 12819;
    };
    "user_name" =     {
        "best_friends" = ();
        score = 58886;
    };
 }
 @endcode */
- (void)bestFriendsOfUsers:(NSArray *)usernames completion:(DictionaryBlock)completion;

- (void)addFriends:(NSArray *)toAdd removeFriends:(NSArray *)toUnfriend completion:(BooleanBlock)completion;

/**
 @c friends is a number->name map, where "name" is the desired screen name of that friend and "number" is their phone number.
 Callback takes an array of SKFoundFriend objects.
 */
- (void)findFriends:(NSDictionary *)friends completion:(ArrayBlock)completion;
/** Not sure what this is for. */
- (void)searchFriend:(NSString *)query completion:(ResponseBlock)completion;

- (void)userExists:(NSString *)username completion:(BooleanBlock)completion;

- (void)updateDisplayNameForUser:(NSString *)friend newName:(NSString *)displayName completion:(ErrorBlock)completion;

@end