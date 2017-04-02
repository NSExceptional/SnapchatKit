//
//  SKNewConversation.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 7/11/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKNewConversation.h"
#import "NSString+SnapchatKit.h"
#import "SKClient.h"

@implementation SKNewConversation

+ (instancetype)newConvoWithAuth:(NSDictionary *)macAndPayload withSender:(NSString *)sender otherUser:(NSString *)recipient {
    return [[self alloc] initWithDictionary:macAndPayload withSender:sender otherUser:recipient];
}

- (id)initWithDictionary:(NSDictionary *)json withSender:(NSString *)sender otherUser:(NSString *)recipient {
    NSParameterAssert(json); NSParameterAssert(recipient); NSParameterAssert(sender);
    
    self = [super init];
    if (self) {
        _recipient     = recipient;
        _messagingAuth = json;
        _mac           = json[@"mac"];
        _payload       = json[@"payload"];
        _state         = @{@"conversation_state": @{@"user_sequences": @{sender: @0, recipient: @0}}};
        _identifier    = [NSString SCIdentifierWith:sender and:recipient];
    }
    
    return self;
}

@end
