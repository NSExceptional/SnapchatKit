//
//  SKClient+Chat.h
//  SnapchatKit
//
//  Created by Tanner on 5/26/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKClient.h"

@interface SKClient (Chat)

/** @param recipients An array of username strings. */
- (void)sendTypingToUsers:(NSArray *)recipients;
- (void)sendTypingToUser:(NSString *)user;
- (void)markRead:(SKConversation *)conversation completion:(BooleanBlock)completion;
- (void)conversationAuth:(NSString *)user completion:(StringBlock)completion;

@end
