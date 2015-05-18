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
    }
    
    return self;
}

@end
