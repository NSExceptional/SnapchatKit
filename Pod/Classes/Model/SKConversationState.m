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
        
        // Case for empty conversations
        if (!sequences.allKeys.count)
            return self;
        
        NSInteger idx = [sequences.allKeys indexOfObject:recipient];
        NSString *sender;
        if (idx == 0)
            sender = releases.allKeys.firstObject;
        else
            sender = sequences.allKeys.firstObject;
        
        // Actual sent values, not percieved values
        _recipientSentCount = [sequences[recipient] integerValue];
        _senderSentCount    = [sequences[sender] integerValue];
        // Unread = actual sent - percieved sent
        _recipientUnreadCount = _senderSentCount    - [releases[recipient][sender] integerValue];
        _senderUnreadCount    = _recipientSentCount - [releases[sender][recipient] integerValue];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ your unread=%@, sent=%@, sender unread=%@, sent=%@>",
            NSStringFromClass(self.class), @(_recipientUnreadCount), @(_recipientSentCount), @(_senderUnreadCount), @(_senderSentCount)];
}

+ (NSArray *)ignoredJSONKeyPathPrefixes {
    static NSArray *ignored = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ignored = @[@"user_chat_releases", @"user_sequences", @"user_snap_releases"];
    });
    
    return ignored;
}

@end
