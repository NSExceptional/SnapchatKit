//
//  SKNearbyUser.m
//  SnapchatKit
//
//  Created by Tanner on 7/3/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKNearbyUser.h"

@implementation SKNearbyUser

+ (instancetype)username:(NSString *)username identifier:(NSString *)identifier {
    return [[self alloc] initWithUsername:username identifier:identifier];
}

- (id)initWithUsername:(NSString *)username identifier:(NSString *)identifier {
    NSParameterAssert(username); NSParameterAssert(identifier);
    
    self = [super init];
    if (self) {
        _username = username;
        _identifier = identifier;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKNearbyUser class]])
        return [self isEqualToNearbyUser:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToNearbyUser:(SKNearbyUser *)user {
    return [user.identifier isEqualToString:self.identifier] && [user.username isEqualToString:self.username];
}

- (NSUInteger)hash {
    return self.identifier.hash ^ self.username.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username=%@, id=%@>",
            NSStringFromClass(self.class), self.username, self.identifier];
}

@end
