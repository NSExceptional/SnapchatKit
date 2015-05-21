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

@end
