//
//  SKAddedFriend.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKAddedFriend.h"

@implementation SKAddedFriend

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    if (self) {
        _addSourceType = SKAddSourceFromString(json[@"add_source_type"]);
        _timestamp = [NSDate dateWithTimeIntervalSince1970:[json[@"ts"] doubleValue]/1000];
    }
    
    [self.knownJSONKeys addObjectsFromArray:@[@"add_source_type", @"ts"]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ add source=%lu, user=%@>",
            NSStringFromClass(self.class), self.addSourceType, [super description]];
}

@end
