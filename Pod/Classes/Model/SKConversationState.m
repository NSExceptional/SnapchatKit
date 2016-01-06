//
//  SKConversationState.m
//  Pods
//
//  Created by Tanner on 1/6/16.
//
//

#import "SKConversationState.h"

@implementation SKConversationState

+ (instancetype)state:(NSDictionary *)json recipient:(NSString *)recipient {
    return [[self alloc] initWithDictionary:json recipient:recipient];
}

- (id)initWithDictionary:(NSDictionary *)json recipient:(NSString *)recipient {
    NSParameterAssert(recipient);
    
    self = [super initWithDictionary:json];
    if (self) {
        NSDictionary *releases  = json[@"user_chat_releases"];
        NSDictionary *sequences = json[@"user_sequences"];
        NSString *sender = sequences.allKeys[![sequences.allKeys indexOfObject:recipient]];
        
        // Actual sent values, not percieved values
        _recipientSentCount = [sequences[recipient] integerValue];
        _senderSentCount    = [sequences[sender] integerValue];
        // Unread = actual sent - percieved sent
        _recipientUnreadCount = _senderSentCount    - [releases[recipient][sender] integerValue];
        _senderUnreadCount    = _recipientSentCount - [releases[sender][recipient] integerValue];
    }
    
    return self;
}

@end
