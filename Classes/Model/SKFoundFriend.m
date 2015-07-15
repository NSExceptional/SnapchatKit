//
//  SKFoundFriend.m
//  SnapchatKit
//
//  Created by Tanner on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKFoundFriend.h"

@implementation SKFoundFriend

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    if (self) {
        _displayName = json[@"display"];
        _username    = json[@"name"];
        _isPrivate   = [json[@"type"] boolValue];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ displayn=%@, username=%@, private=%d>",
            NSStringFromClass(self.class), self.displayName, self.username, self.isPrivate];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKFoundFriend class]])
        return [self isEqualToFoundFriend:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToFoundFriend:(SKFoundFriend *)found {
    return [self.username isEqualToString:found.username];
}

@end
