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

/** Sends the typing notification to the given users.
 @param recipients An array of username strings.*/
- (void)sendTypingToUsers:(NSArray *)recipients;
/** Sends the typing notification to a single user. */
- (void)sendTypingToUser:(NSString *)username;
/** Not working, but is supposed to mark all chat messages in a conversation as read.
 @param completion Takes an error, if any. */
- (void)markRead:(SKConversation *)conversation completion:(ErrorBlock)completion;
/** Retrieves the conversation auth mac and payload for a conversation with \c user.
 @param completion Takes an error, if any, and a dictionary with keys \c "mac" and \c "payload" */
- (void)conversationAuth:(NSString *)username completion:(DictionaryBlock)completion;
/** Retrieves the conversation with \e username.
 @param completion Takes an error, if any, and an \c SKConversation object. */
- (void)conversationWithUser:(NSString *)username completion:(ResponseBlock)completion;
/** Fetches the conversations for all users in \e usernames
 @param completion Takes an error, if any, an array \e conversations of \c SKCovnersation objects, and an array \e failed of usernames indicating conversations unable to be retrieved. */
- (void)conversationsWithUsers:(NSArray *)usernames completion:(void (^)(NSArray *conversations, NSArray *failed, NSError *error))completion;

/** Clears the conversation with the given identifier.
 @param identifier The identifier of the conversation to clear.
 @param completion Takes an error, if any. */
- (void)clearConversationWithIdentifier:(NSString *)identifier completion:(ErrorBlock)completion;
/** Clears the entire feed.
 @param completion Takes an error, if any. */
- (void)clearFeed:(ErrorBlock)completion;

/** Sends a message \e message to \e username.
 @param message The message to send.
 @param username The username of the recipient.
 @param completion Takes an error, if any, and an \c SKConversation object. */
- (void)sendMessage:(NSString *)message to:(NSString *)username completion:(ResponseBlock)completion;
/** Sends a message \e message to each user in \e recipients.
 @param message The message to send.
 @param recipients An array of username strings.
 @param completion Takes an error, if any, an array \e conversations of \c SKConversation objects, and an array \e failed of usernames who could not be sent the message. */
- (void)sendMessage:(NSString *)message toEach:(NSArray *)recipients completion:(void (^)(NSArray *conversations, NSArray *failed, NSError *error))completion;

#pragma mark Loading old data

/** Loads another page of conversations in the feed after the given conversation.
 @discussion This method will update \c [SKClient sharedClient],currentSession.conversations accordingly.
 @param conversation The conversation after which to load more conversations.
 @param completion Takes an error, if any, and an array of \c SKConversation objects. */
- (void)loadConversationsAfter:(SKConversation *)conversation completion:(ArrayBlock)completion;
/** Loads every conversation.
 @discussion This method will update \c [SKClient sharedClient].currentSession.conversations accordingly.
 @param completion Takes an error, if any, and an array of fetched SKConversation objects.
 @note \e completion will still take an error if it retrieved some conversations, but failed to get the rest after some point. */
- (void)allConversations:(ArrayBlock)completion;
/** Loads more messages after the given message or cash transaction.
 @param messageOrTransaction any object conforming to SKPagination \b EXCEPT AN \C SKConversation.
 @warning Do not pass an \c SKConversation object to messageOrTransaction. Doing so will raise an exception.
 @param completion Takes an error, if any, and a new \c SKConversation with (only) the additional messages, or \c nil if no more could be loaded. */
- (void)loadMessagesAfterPagination:(SKThing<SKPagination> *)messageOrTransaction completion:(ResponseBlock)completion;
/** Loads every message in the given thread and adds them to that SKConversation object.
 @param conversation The conversation to load completely.
 @param completion Takes an error, if any. */
- (void)fullConversation:(SKConversation *)conversation completion:(ErrorBlock)completion;

@end
