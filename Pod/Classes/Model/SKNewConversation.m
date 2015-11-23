//
//  SKNewConversation.m
//  SnapchatKit-iOS-Demo
//
//  Created by Tanner on 7/11/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKNewConversation.h"
#import "NSString+SnapchatKit.h"
#import "SKClient.h"

@implementation SKNewConversation

+ (instancetype)newConvoWithAuth:(NSDictionary *)macAndPayload withOtherUser:(NSString *)recipient {
    return [[self alloc] initWithDictionary:macAndPayload otherUser:recipient];
}

- (id)initWithDictionary:(NSDictionary *)json { [NSException raise:NSInternalInconsistencyException format:@"Do not initialize this class with this method"]; return nil; }

- (id)initWithDictionary:(NSDictionary *)json otherUser:(NSString *)recipient {
    NSParameterAssert(json); NSParameterAssert(recipient);
    
    self = [super initWithDictionary:json];
    if (self) {
        _recipient     = recipient;
        _messagingAuth = json;
        _mac           = json[@"mac"];
        _payload       = json[@"payload"];
        _state         = @{@"conversation_state": @{@"user_sequences": @{recipient: @0, [SKClient sharedClient].username: @0}}};
        _identifier    = [NSString SCIdentifierWith:[SKClient sharedClient].username and:recipient];
    }
    
    return self;
}

@end
