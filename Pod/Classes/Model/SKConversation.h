//
//  SKConversation.h
//  SnapchatKit
//
//  Created by Tanner on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"
@class SKSnap, SKCashTransaction;

typedef NS_ENUM(NSUInteger, SKChatType)
{
    SKChatTypeNever,
    SKChatTypeText,
    SKChatTypeMedia
};

extern SKChatType SKChatTypeFromString(NSString *chatTypeString);

@interface SKConversation : SKThing <SKPagination>

/** Ordered set of SKSnap SKMessage, and SKCashTransaction objects. Possibly some transactions in the JSON that I'm not aware of. */
@property (nonatomic, readonly) NSOrderedSet *messages;
/** Keys are "mac" and "payload" */
@property (nonatomic, readonly) NSDictionary *messagingAuth;

/**
 Keys:

 - "user_chat_releases"
    Contains a dictionary with keys for each participant,
    mapping the number of messages from each participant, as
    they see it. So if Bob sends Sally a message and Sally hasn't
    read it, state["user_chat_releases"]["Sally"]["Bob"] will
    be one less than state["user_chat_releases"]["Bob"]["Sally"],
    because Sally has not read it yet but Bob can see it.
 
 - "user_sequences"
    A dictionary with keys for each participant, mapping
    the total number of messages and snaps sent by that user.
 
 - "user_snap_releases"
    Same as "user_chat_releases" but with timestamps. Might just be for snaps.
 */
@property (nonatomic, readonly) NSDictionary *state;
@property (nonatomic, readonly) NSString     *identifier;
/** Pagination token used to load older conversations. */
@property (nonatomic, readonly) NSString     *pagination;

@property (nonatomic, readonly) SKChatType   lastChatType;
/** \c nil if not applicable. */
@property (nonatomic, readonly) SKSnap       *lastSnap;
/** \c nil if not applicable. */
@property (nonatomic, readonly) NSDate       *lastInteraction;
/** \c nil if not applicable. */
@property (nonatomic, readonly) NSDate       *lastNotified;
/** \c nil if not applicable. */
@property (nonatomic, readonly) NSDate       *lastChatRead;
/** \c nil if not applicable. */
@property (nonatomic, readonly) NSDate       *lastChatWrite;
/** \c nil if not applicable. */
@property (nonatomic, readonly) NSString     *lastChatReader;
/** \c nil if not applicable. */
@property (nonatomic, readonly) NSString     *lastChatWriter;

/** \c nil if not applicable. */
@property (nonatomic, readonly) SKCashTransaction *lastTransaction;

/** Array of username strings. */
@property (nonatomic, readonly) NSArray      *participants;
/** Array of username strings. */
@property (nonatomic, readonly) NSArray      *usersWithPendingChats;
/** Array of SKSnap objects. */
@property (nonatomic, readonly) NSArray      *pendingRecievedSnaps;

/** @param participant Must be in \c participants. @return An array of \c SKMessage objects, or an empty array if N/A. */
- (NSArray *)unreadChatsForParticipant:(NSString *)participant;

/** Merges _messages with conversation.messages. */
- (void)addMessagesFromConversation:(SKConversation *)conversation;

@end

@interface SKConversation (SKClient)
/** Returns the (first) participant that is not the current user. */
@property (nonatomic, readonly) NSString *recipient;
/** All messages in a human-readable, newline separated format. */
@property (nonatomic, readonly) NSString *conversationString;
@end