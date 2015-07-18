//
//  SKSimpleUser.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSimpleUser.h"



@implementation SKSimpleUser

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    if (self) {
        _username       = json[@"name"];
        _displayName    = [json[@"display"] length] ? json[@"display"] : nil;
        _userIdentifier = json[@"user_id"];
        _addedIncoming  = [json[@"direction"] isEqualToString:@"INCOMING"];
        _ignoredLink    = [json[@"ignored_link"] boolValue];
        _privacy        = [json[@"type"] integerValue];
        _expiration     = [NSDate dateWithTimeIntervalSince1970:[json[@"expiration"] doubleValue]/1000];
    }
    
    [[self class] addKnownJSONKeys:@[@"name", @"display", @"user_id", @"direction", @"type", @"expiration", @"ignored_link"]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username=%@, displayn=%@, incoming=%d>",
            NSStringFromClass(self.class), self.username, self.displayName, self.addedIncoming];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKSimpleUser class]])
        return [self isEqualToSimpleUser:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToSimpleUser:(SKSimpleUser *)user {
    return [self.username isEqualToString:user.username];
}

- (NSUInteger)hash {
    return self.username.hash;
}

@end
