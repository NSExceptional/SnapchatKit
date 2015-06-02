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

- (void)addFriend:(NSString *)username completion:(DictionaryBlock)completion;
- (void)unfriend:(NSString *)friend completion:(DictionaryBlock)completion;
- (void)bestFriendsOfUsers:(NSArray *)usernames completion:(DictionaryBlock)completion;

@end