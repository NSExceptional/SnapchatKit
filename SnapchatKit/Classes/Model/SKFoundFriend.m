//
//  SKFoundFriend.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKFoundFriend.h"

@implementation SKFoundFriend

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ displayn=%@, username=%@, private=%d>",
            NSStringFromClass(self.class), self.displayName, self.username, self.isPrivate];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"displayName": @"diplay",
             @"username": @"name",
             @"isPrivate": @"type"};
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKFoundFriend class]])
        return [self isEqualToFoundFriend:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToFoundFriend:(SKFoundFriend *)found {
    return [self.username isEqualToString:found.username];
}

@end
