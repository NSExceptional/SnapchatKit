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

SKChatType SKChatTypeFromString(NSString *chatTypeString) {
    if ([chatTypeString isEqualToString:@"text"])
        return SKChatTypeText;
    if ([chatTypeString isEqualToString:@"media"])
        return SKChatTypeMedia;
    
    return SKChatTypeNever;
}

@implementation SKConversation

- (id)initWithDictionary:(NSDictionary *)json {
    NSDictionary *convoMessages   = json[@"conversation_messages"];
    NSDictionary *lastChatActions = json[@"last_chat_actions"];
    NSDictionary *lastTransaction = json[@"last_cash_transaction"];
    NSArray *pendingRecievedSnaps = json[@"pending_received_snaps"];
    NSArray *messages             = convoMessages[@"messages"];
    
    self = [super initWithDictionary:json];
    if (self) {
        _messagingAuth = convoMessages[@"messaging_auth"];
        
        _state      = json[@"conversation_state"];
        _identifier = json[@"id"];
        _iterToken  = json[@"iter_token"];
        
        _lastSnap        = [[SKSnap alloc] initWithDictionary:json[@"last_snap"]];
        _lastTransaction = lastTransaction ? [[SKCashTransaction alloc] initWithDictionary:lastTransaction] : nil;
        _lastInteraction = [NSDate dateWithTimeIntervalSince1970:[json[@"last_interaction_ts"] doubleValue]/1000];
        if (lastChatActions) {
            _lastChatType    = SKChatTypeFromString(lastChatActions[@"last_write_type"]);
            _lastChatRead    = [NSDate dateWithTimeIntervalSince1970:[lastChatActions[@"last_read_timestamp"] doubleValue]/1000];
            _lastChatWrite   = [NSDate dateWithTimeIntervalSince1970:[lastChatActions[@"last_write_timestamp"] doubleValue]/1000];
            _lastChatReader  = lastChatActions[@"last_reader"];
            _lastChatWriter  = lastChatActions[@"last_writer"];
        }
        
        _participants = json[@"participants"];
        _usersWithPendingChats = json[@"pending_chats_for"];
        
        // Messages
        NSMutableArray *temp = [NSMutableArray new];
        for (NSDictionary *message in messages) {
            if (message[@"snap"])
                [temp addObject:[[SKSnap alloc] initWithDictionary:message[@"snap"]]];
            else if (message[@"chat_message"])
                [temp addObject:[[SKMessage alloc] initWithDictionary:message]];
            else
                NSLog(@"Unhandled conversation message type:\n%@", message);
        }
        _messages = temp;
        
        // Pending recieved snaps
        temp = [NSMutableArray new];
        for (NSDictionary *snap in pendingRecievedSnaps)
            [temp addObject:[[SKSnap alloc] initWithDictionary:snap]];
        _pendingRecievedSnaps = temp;
    }
    
    [self.knownJSONKeys addObjectsFromArray:@[@"conversation_messages", @"last_chat_actions", @"pending_received_snaps", @"conversation_state", @"id",
                                              @"iter_token", @"last_snap", @"last_cash_transaction", @"last_interaction_ts", @"participants", @"pending_chats_for"]];
    
    return self;
}

- (NSString *)description {
    NSUInteger c = self.participants.count;
    NSString *participants = c == 0 ? @"{n/a}" : c == 1 ? self.participants[0] : [NSString stringWithFormat:@"%@ and %@", self.participants[0], self.participants[1]];
    return [NSString stringWithFormat:@"<%@ participants: %@, messages=%lu, unread=%lu>",
            NSStringFromClass(self.class), participants, self.messages.count, self.pendingRecievedSnaps.count];
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
            NSLog(@"0 unread count, but [%@] has pending chats from %@.", participant, user);
            break;
        }
        if (totalUnread < 0) {
            NSLog(@"Negative unread count between users: [%@] and %@.", participant, user);
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

@end
