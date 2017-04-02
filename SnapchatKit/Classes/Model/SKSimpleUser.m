//
//  SKSimpleUser.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSimpleUser.h"


@implementation SKSimpleUser

- (id)initWithDictionary:(NSDictionary *)json error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:json error:error];
    if (self) {
        if (!_displayName.length) _displayName = nil;
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)json {
    // API debugging
    if (![json[@"direction"] isEqualToString:@"OUTGOING"] && ![json[@"direction"] isEqualToString:@"INCOMING"])
        SKLog(@"SKSimpleUser new 'direction': %@", json[@"direction"]);
    
    return [super initWithDictionary:json];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username=%@, displayn=%@, incoming=%d>",
            NSStringFromClass(self.class), _username, _displayName, _addedIncoming];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"username": @"name",
             @"displayName": @"display",
             @"userIdentifier": @"user_id",
             @"addedIncoming": @"direction",
             @"ignoredLink": @"ignored_link",
             @"expiration": @"expiration",
             @"addedBack": @"reverse_ts",
             @"friendStatus": @"type"};
}

+ (NSValueTransformer *)addedIncomingJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{@"INCOMING": @YES, @"OUTGOING": @NO} defaultValue:@NO reverseDefaultValue:@"__unspecified"];
}

MTLTransformPropertyDate(expiration)
MTLTransformPropertyDate(addedBack)

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKSimpleUser class]])
        return [self isEqualToSimpleUser:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToSimpleUser:(SKSimpleUser *)user {
    return [_username isEqualToString:user.username];
}

- (NSUInteger)hash {
    return _username.hash;
}

@end
