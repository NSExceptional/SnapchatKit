//
//  SKSimpleUser.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSimpleUser.h"



@implementation SKSimpleUser

+ (instancetype)userFromResponse:(NSDictionary *)json {
    return [[self.class alloc] initWithDictionary:json];
}

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    if (self) {
        _username      = json[@"name"];
        _displayName   = json[@"display"];
        _addedIncoming = [json[@"direction"] isEqualToString:@"INCOMING"];
        _type          = [json[@"type"] integerValue];
        _expiration    = [NSDate dateWithTimeIntervalSince1970:[json[@"expiration"] doubleValue]/1000];
    }
    
    [self.knownJSONKeys addObjectsFromArray:@[@"name", @"display", @"direction", @"type", @"expiration"]];
    
    return self;
}

@end
