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
        _addSource     = json[@"add_source"];
        _addSourceType = SKAddSourceFromString(json[@"add_source_type"]);
        _timestamp     = [NSDate dateWithTimeIntervalSince1970:[json[@"ts"] doubleValue]/1000];
        _pendingSnaps  = [json[@"pending_snaps_count"] integerValue];
    }
    
    [[self class] addKnownJSONKeys:[@[@"add_source", @"add_source_type", @"ts", @"pending_snaps_count"] arrayByAddingObjectsFromArray:[self.superclass knownJSONKeys]]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ add source=%lu, username=%@, displayn=%@>",
            NSStringFromClass(self.class), (unsigned long)self.addSourceType, self.username, self.displayName];
}

@end
