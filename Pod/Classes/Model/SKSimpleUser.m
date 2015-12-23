//
//  SKSimpleUser.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSimpleUser.h"



@implementation SKSimpleUser

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    
    // API debugging
    if (![json[@"direction"] isEqualToString:@"OUTGOING"] && ![json[@"direction"] isEqualToString:@"INCOMING"])
        SKLog(@"SKSimpleUser new 'direction': %@", json[@"direction"]);
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username=%@, displayn=%@, incoming=%d>",
            NSStringFromClass(self.class), self.username, self.displayName, self.addedIncoming];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"username": @"name",
             @"displayName": @"display",
             @"userIdentifier": @"user_id",
             @"addedIncoming": @"direction",
             @"ignoredLink": @"ignored_link",
             @"privacy": @"type",
             @"expiration": @"expiration"};
}

+ (NSValueTransformer *)addedIncomingJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{@"INCOMING": @YES, @"OUTGOING": @NO} defaultValue:@NO reverseDefaultValue:@"__unspecified"];
}

MTLTransformPropertyDate(expiration)

#pragma mark - Equality

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
