//
//  SKConversation.h
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"
@class SKSnap, SKCashTransaction, SKMessage, SKConversationState;

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

@property (nonatomic, readonly) NSString     *identifier;
/** Pagination token used to load older conversations. */
@property (nonatomic, readonly) NSString     *pagination;

@property (nonatomic, readonly) SKChatType   lastChatType;
/** \c nil if not applicable. */
@property (nonatomic, readonly) SKSnap       *lastSnap;
/** @discussion This property has O(n) access time the first time you call it, and whenever
 the first message in \c messages changes. Otherwise has constant access time. */
@property (nonatomic, readonly) SKMessage    *lastChatMessage;
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
/** A string representing the last chat interaction (i.e. the last message, or a message describing a snap or cash transaction. */
@property (nonatomic, readonly) NSString     *suggestedChatPreview;

/** \c nil if not applicable. */
@property (nonatomic, readonly) SKCashTransaction   *lastTransaction;
@property (nonatomic, readonly) SKConversationState *state;
@property (nonatomic, readonly) NSDictionary        *stateDict;

/** The current signed in user. */
@property (nonatomic, readonly) NSString     *recipient;
/** The first participant that is not the recipient, or the first participant. */
@property (nonatomic, readonly) NSString     *sender;
/** Array of username strings. */
@property (nonatomic, readonly) NSArray      *participants;
/** Array of username strings. */
@property (nonatomic, readonly) NSArray      *usersWithPendingChats;
/** Array of SKSnap objects. */
@property (nonatomic, readonly) NSArray      *pendingRecievedSnaps;
/** @discussion This property has O(n) access time the first time you call it, and whenever
 the first message in \c messages changes. Otherwise has constant access time. */
@property (nonatomic, readonly) BOOL         lastChatWasOutgoing;


/** @param participant Must be in \c participants. @return An array of \c SKMessage objects, or an empty array if N/A. */
- (NSArray *)unreadChatsForParticipant:(NSString *)participant;

/** Merges _messages with conversation.messages. */
- (void)addMessagesFromConversation:(SKConversation *)conversation;

@end

@interface SKConversation (SKClient)
/** Whether or not \c user has unread messages. */
- (BOOL)userHasUnreadChats:(NSString *)user;
/** All messages in a human-readable, newline separated format. */
@property (nonatomic, readonly) NSString *conversationString;
@end