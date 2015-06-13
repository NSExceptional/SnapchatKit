//
//  SKClient+Chat.h
//  SnapchatKit
//
//  Created by Tanner on 5/26/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKClient.h"

// TODO: timeout for methods that take an array of usernames

@interface SKClient (Chat)

/** @param recipients An array of username strings. */
- (void)sendTypingToUsers:(NSArray *)recipients;
- (void)sendTypingToUser:(NSString *)user;
- (void)markRead:(SKConversation *)conversation completion:(BooleanBlock)completion;
/** Keys are "mac" and "payload" */
- (void)conversationAuth:(NSString *)user completion:(DictionaryBlock)completion;
/** Callback takes an SKConversation object. */
- (void)conversationWithUser:(NSString *)user completion:(ResponseBlock)completion;
/** conversations is an array of SKCovnersation objects, failed is an array of usernames indicating conversations unable to be retrieved. */
- (void)conversationsWithUsers:(NSArray *)users completion:(void (^)(NSArray *conversations, NSArray *failed, NSError *error))completion;

/** Callback takes an SKConversation object. */
- (void)sendMessage:(NSString *)message to:(NSString *)username completion:(ResponseBlock)completion;
/** Callback takes an array of SKConversation objects and an array of usernames who could not be sent the message. */
- (void)sendMessage:(NSString *)message toEach:(NSArray *)recipients completion:(void (^)(NSArray *conversations, NSArray *failed, NSError *error))completion;

#pragma mark Loading old data

/** Loads another page of conversations in the feed after the given conversation and updates _currentSession.conversations accordingly. Callback takes an array of SKConversation objects. */
- (void)loadConversationsAfter:(SKConversation *)conversation completion:(ArrayBlock)completion;
/** Loads every conversation and updates _currentSession.conversations accordingly. Callback takes an array of fetched SKConversation objects, AND an error if it failed to get the rest at some point. */
- (void)allConversations:(ArrayBlock)completion;
/**
 Loads more messages after the given message or transaction. Callback takes a new SKConversation with (only) the additional messages, or nil if no more could be loaded.
 @warning Do not pass an SKConversation object to messageOrTransaction.
 */
- (void)loadMessagesAfterPagination:(SKThing<SKPagination> *)messageOrTransaction completion:(ResponseBlock)completion;
/** Loads every message in the given thread and adds them to that SKConversation object. */
- (void)fullConversation:(SKConversation *)conversation completion:(ErrorBlock)completion;

@end
