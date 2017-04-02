//
//  SKNearbyUser.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 7/3/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKNearbyUser.h"

@implementation SKNearbyUser

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username=%@, id=%@>",
            NSStringFromClass(self.class), _username, _identifier];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"username": @"username",
             @"identifier": @"user_id"};
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKNearbyUser class]])
        return [self isEqualToNearbyUser:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToNearbyUser:(SKNearbyUser *)user {
    return [user.identifier isEqualToString:_identifier] && [user.username isEqualToString:_username];
}

- (NSUInteger)hash {
    return self.identifier.hash ^ self.username.hash;
}

@end
