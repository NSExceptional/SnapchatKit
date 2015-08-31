//
//  SKConversation.m
//  SnapchatKit
//
//  Created by Tanner on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKConversation.h"
#import "SKSnap.h"
#import "SKMessage.h"
#import "SKCashTransaction.h"

#import "SKClient.h"

SKChatType SKChatTypeFromString(NSString *chatTypeString) {
    if ([chatTypeString isEqualToString:@"text"])
        return SKChatTypeText;
    if ([chatTypeString isEqualToString:@"media"])
        return SKChatTypeMedia;
    
    return SKChatTypeNever;
}

@implementation SKConversation

- (id)initWithDictionary:(NSDictionary *)json {
    NSParameterAssert(json.allKeys.count > 2);
    // Required keys: conversation_messages, conversation_state, id
    
    self = [super initWithDictionary:json];
    
    NSDictionary *convoMessages   = json[@"conversation_messages"];
    NSDictionary *lastChatActions = json[@"last_chat_actions"];
    NSDictionary *lastTransaction = json[@"last_cash_transaction"];
    NSArray *pendingRecievedSnaps = json[@"pending_received_snaps"];
    NSArray *messages             = convoMessages[@"messages"];
    NSDictionary *lastSnap        = json[@"last_snap"];
    CGFloat lastInteraction       = [json[@"last_interaction_ts"] doubleValue];
    CGFloat lastNotified          = [json[@"last_notified"] doubleValue];
    
    if (self) {
        _messagingAuth = convoMessages[@"messaging_auth"];
        
        _state      = json[@"conversation_state"];
        _identifier = json[@"id"];
        _pagination = json[@"iter_token"];
        
        _lastSnap        = lastSnap ? [[SKSnap alloc] initWithDictionary:lastSnap] : nil;
        _lastTransaction = lastTransaction ? [[SKCashTransaction alloc] initWithDictionary:lastTransaction] : nil;
        _lastInteraction = lastInteraction > 0 ? [NSDate dateWithTimeIntervalSince1970:lastInteraction/1000] : nil;
        _lastNotified    = lastNotified > 0 ? [NSDate dateWithTimeIntervalSince1970:lastNotified/1000] : nil;
        if (lastChatActions) {
            _lastChatType    = SKChatTypeFromString(lastChatActions[@"last_write_type"]);
            _lastChatRead    = [NSDate dateWithTimeIntervalSince1970:[lastChatActions[@"last_read_timestamp"] doubleValue]/1000];
            _lastChatWrite   = [NSDate dateWithTimeIntervalSince1970:[lastChatActions[@"last_write_timestamp"] doubleValue]/1000];
            _lastChatReader  = lastChatActions[@"last_reader"];
            _lastChatWriter  = lastChatActions[@"last_writer"];
        }
        
        _participants = json[@"participants"] ?: [_identifier componentsSeparatedByString:@"~"];
        _usersWithPendingChats = json[@"pending_chats_for"] ?: @[];
        
        // Messages
        NSMutableOrderedSet *temp = [NSMutableOrderedSet orderedSet];
        for (NSDictionary *message in messages) {
            if (message[@"snap"])
                [temp addObject:[[SKSnap alloc] initWithDictionary:message[@"snap"]]];
            else if (message[@"chat_message"])
                [temp addObject:[[SKMessage alloc] initWithDictionary:message]];
            else if (message[@"cash_transaction"])
                [temp addObject:[[SKCashTransaction alloc] initWithDictionary:message]];
            else
                SKLog(@"Unhandled conversation message type:\n%@", message);
        }
        _messages = temp;
        
        // Pending recieved snaps
        NSMutableArray *tmp = [NSMutableArray new];
        for (NSDictionary *snap in pendingRecievedSnaps)
            [tmp addObject:[[SKSnap alloc] initWithDictionary:snap]];
        _pendingRecievedSnaps = tmp;
    }
    
    [[self class] addKnownJSONKeys:@[@"conversation_messages", @"last_chat_actions", @"pending_received_snaps", @"conversation_state", @"id",
                                     @"iter_token", @"last_snap", @"last_cash_transaction", @"last_interaction_ts", @"participants", @"pending_chats_for",
                                     @"last_notified"]];
    
    return self;
}

- (NSString *)description {
    NSUInteger c = self.participants.count;
    NSString *participants = c == 0 ? @"{n/a}" : c == 1 ? self.participants[0] : [NSString stringWithFormat:@"%@ and %@", self.participants[0], self.participants[1]];
    return [NSString stringWithFormat:@"<%@ participants: %@, messages=%lu, unread=%lu>",
            NSStringFromClass(self.class), participants, (unsigned long)self.messages.count, (unsigned long)self.pendingRecievedSnaps.count];
}

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

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKConversation class]])
        return [self isEqualToConversation:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToConversation:(SKConversation *)conversation {
    return [self.identifier isEqualToString:conversation.identifier];
}

@end

@implementation SKConversation (SKClient)

- (NSString *)recipient {
    if (![SKClient sharedClient].username.length) return nil;
    return [self.participants[0] isEqualToString:[SKClient sharedClient].username] ? self.participants[1] : self.participants[0];
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