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
- (void)bestFriendsOfUsers:(NSArray *)usernames completion:(DictionaryBlock)completion;

@end