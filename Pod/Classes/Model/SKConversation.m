//
//  SKConversation.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKConversation.h"
#import "SKSnap.h"
#import "SKMessage.h"
#import "SKCashTransaction.h"

#import "SKClient.h"

#import "NSArray+SnapchatKit.h"

SKChatType SKChatTypeFromString(NSString *chatTypeString) {
    if ([chatTypeString isEqualToString:@"text"])
        return SKChatTypeText;
    if ([chatTypeString isEqualToString:@"media"])
        return SKChatTypeMedia;
    
    return SKChatTypeNever;
}

NSString * SKStringFromChatType(SKChatType chatType) {
    switch (chatType) {
        case SKChatTypeNever: {
            return nil;
        }
        case SKChatTypeText: {
            return @"text";
        }
        case SKChatTypeMedia: {
            return @"media";
        }
    }
    
    [NSException raise:NSInternalInconsistencyException format:@"Invalid chat type: %@", @(chatType).stringValue];
    return nil;
}

@implementation SKConversation

- (id)initWithDictionary:(NSDictionary *)json {
    NSParameterAssert(json.allKeys.count > 2);
    // Required keys: conversation_messages, conversation_state, id
    
    self = [super initWithDictionary:json];
    
    if (self) {
        if (!_participants.count)
            _participants = [_identifier componentsSeparatedByString:@"~"];
        if (!_usersWithPendingChats)
            _usersWithPendingChats = @[];
    }
    
    return self;
}

- (NSString *)description {
    NSUInteger c = self.participants.count;
    NSString *participants = c == 0 ? @"{n/a}" : c == 1 ? self.participants[0] : [NSString stringWithFormat:@"%@ and %@", self.participants[0], self.participants[1]];
    return [NSString stringWithFormat:@"<%@ participants: %@, messages=%lu, unread=%lu>",
            NSStringFromClass(self.class), participants, (unsigned long)self.messages.count, (unsigned long)self.pendingRecievedSnaps.count];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"messagingAuth": @"conversation_messages.messaging_auth",
             @"state": @"conversation_state",
             @"identifier": @"id",
             @"pagination": @"iter_token",
             @"lastSnap": @"last_snap",
             @"lastTransaction": @"last_cash_transaction",
             @"lastInteraction": @"last_interaction_ts",
             @"lastNotified": @"last_notified",
             @"lastChatType": @"last_chat_actions.last_write_type",
             @"lastChatRead": @"last_chat_actions.last_read_timestamp",
             @"lastChatWrite": @"last_chat_actions.last_write_timestamp",
             @"lastChatReader": @"last_chat_actions.last_reader",
             @"lastChatWriter": @"last_chat_actions.last_writer",
             @"participants": @"participants",
             @"usersWithPendingChats": @"pending_chats_for",
             @"messages": @"conversation_messages.messages",
             @"pendingRecievedSnaps": @"pending_received_snaps"};
}

MTLTransformPropertyDate(lastInteraction)
MTLTransformPropertyDate(lastNotified)
MTLTransformPropertyDate(lastChatRead)
MTLTransformPropertyDate(lastChatWrite)
+ (NSValueTransformer *)pendingRecievedSnapsJSONTransformer { return [self sk_modelArrayTransformerForClass:[SKSnap class]]; }

+ (NSValueTransformer *)lastChatTypeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *type, BOOL *success, NSError *__autoreleasing *error) {
        return @(SKChatTypeFromString(type));
    } reverseBlock:^id(NSNumber *type, BOOL *success, NSError *__autoreleasing *error) {
        return SKStringFromChatType(type.integerValue);
    }];
}

+ (NSValueTransformer *)messagesJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *messages, BOOL *success, NSError *__autoreleasing *error) {
        NSMutableArray *temp = [NSMutableArray new];
        for (NSDictionary *message in messages) {
            if (message[@"snap"])
                [temp addObject:[[SKSnap alloc] initWithDictionary:message[@"snap"]]];
            else if (message[@"chat_message"])
                [temp addObject:[[SKMessage alloc] initWithDictionary:message]];
            else if (message[@"cash_transaction"])
                [temp addObject:[[SKCashTransaction alloc] initWithDictionary:message]];
            else
                SKLog(@"Unhandled conversation message type:\n%@", message);
        };
        return temp;
    } reverseBlock:^id(NSArray *messages, BOOL *success, NSError *__autoreleasing *error) {
        return messages.dictionaryValues;
    }];
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKConversation class]])
        return [self isEqualToConversation:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToConversation:(SKConversation *)conversation {
    return [self.identifier isEqualToString:conversation.identifier];
}

#pragma mark - Convenience

- (NSArray *)unreadChatsForParticipant:(NSString *)participant {
    NSParameterAssert([self.participants containsObject:participant]);
    
    if (![self.usersWithPendingChats containsObject:participant])
        return @[];
    
    NSMutableArray *unread = [NSMutableArray new];
    NSMutableArray *others = self.participants.mutableCopy;
    [others removeObject:participant];
    
    // Iterate over other participants, excluding "participant"
    for (NSString *user in others) {
        NSUInteger seenByParticipant = [self.state[@"user_chat_releases"][participant][user] integerValue];
        NSUInteger sentByUser        = [self.state[@"user_sequences"][user] integerValue];
        NSInteger totalUnread        = sentByUser - seenByParticipant;
        
        // Possible unhandled cases
        if (totalUnread == 0) {
            SKLog(@"0 unread count, but [%@] has pending chats from %@.", participant, user);
            break;
        }
        if (totalUnread < 0) {
            SKLog(@"Negative unread count between users: [%@] and %@.", participant, user);
            break;
        }
        
        __block NSUInteger found = 0;
        [self.messages enumerateObjectsUsingBlock:^(SKThing *thing, NSUInteger i, BOOL *stop) {
            // Ignore snaps
            if ([thing isKindOfClass:[SKSnap class]])
                return;
            
            // Check if message was sent to participant,
            // increment found count
            SKMessage *message = (SKMessage *)thing;
            if ([message.recipients containsObject:participant]) {
                [unread addObject:message];
                found++;
                if (found == totalUnread)
                    *stop = YES;
            }
        }];
    }
    
    return unread;
}

- (void)addMessagesFromConversation:(SKConversation *)conversation {
    if (!conversation.messages.count) return;
    
    // Internally, this set is mutable.
    NSMutableOrderedSet *mutableMessages = (NSMutableOrderedSet *)self.messages;
    [mutableMessages addObjectsFromArray:conversation.messages.array];
}

- (NSString *)suggestedChatPreview {
    for (id message in self.messages) {
        Class cls = [message class];
        if (cls == [SKSnap class]) continue;
        
        if (cls == [SKMessage class]) {
            SKMessage *mess = (id)message;
            return mess.text ?: [mess.sender stringByAppendingString:@"sent a picture."];
            
        } else if (cls == [SKCashTransaction class]) {
            SKCashTransaction *cash = (id)message;
            return [NSString stringWithFormat:@"%@ sent %@", cash.sender, cash.message];
        }
        
        [NSException raise:NSInternalInconsistencyException format:@"Unknown class in SKConversation.messages: %@", cls];
        return nil;
    }
    
    return @"";
}

- (void)setRecipient:(NSString *)recipient {
    NSParameterAssert(recipient);
    _recipient = recipient;
}

@end

@implementation SKConversation (SKClient)

- (NSString *)recipientGivenUser:(NSString *)user {
    if (user) return nil;
    return [self.participants[0] isEqualToString:user] ? self.participants[1] : self.participants[0];
}

- (BOOL)userHasUnreadChats:(NSString *)user {
    NSString *sender       = [self recipientGivenUser:user];
    NSUInteger yourCount   = [self.state[@"user_chat_releases"][user][sender] integerValue];
    NSUInteger senderCount = [self.state[@"user_chat_releases"][sender][user] integerValue];
    
    return yourCount < senderCount;
}

- (NSString *)conversationString {
    NSString *username = [SKClient sharedClient].username;
    NSString *other    = self.recipient;
    NSUInteger minlen  = MAX(username.length, other.length) + 1;
    NSMutableString *string = [NSMutableString string];
    
    for (SKThing *thing in self.messages.reverseObjectEnumerator) {
        if ([thing isKindOfClass:[SKSnap class]]) {
            SKSnap *snap = (SKSnap *)thing;
            NSString *sender = [NSString stringWithFormat:@"%@:", snap.sender ?: username];
            sender = [sender stringByPaddingToLength:minlen withString:@" " startingAtIndex:0];
            [string appendFormat:@"%@  %@", sender, SKStringFromMediaKind(snap.mediaKind)];
            
        } else if ([thing isKindOfClass:[SKMessage class]]) {
            SKMessage *message = (SKMessage *)thing;
            NSString *sender = [NSString stringWithFormat:@"%@:", message.sender];
            sender = [sender stringByPaddingToLength:minlen withString:@" " startingAtIndex:0];
            [string appendFormat:@"%@  %@", sender, message.text ?: @"SKMessageKindMedia"];
            
        } else if ([thing isKindOfClass:[SKCashTransaction class]]) {
            SKCashTransaction *transaction = (SKCashTransaction *)thing;
            NSString *sender = [NSString stringWithFormat:@"%@:", transaction.sender];
            sender = [sender stringByPaddingToLength:minlen withString:@" " startingAtIndex:0];
            [string appendFormat:@"%@  %@", sender, transaction.message];
            
        }
        [string appendString:@"\n"];
    }
    
    return string;
}

@end