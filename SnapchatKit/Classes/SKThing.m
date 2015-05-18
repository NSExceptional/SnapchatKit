//
//  SKThing.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"


@interface SKThing ()
@property (nonatomic, readonly) NSDictionary *JSON;
@end

@implementation SKThing

- (id)initWithDictionary:(NSDictionary *)json {
    NSParameterAssert(json);
    
    self = [super init];
    if (self) {
        _JSON = json;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [[self.class alloc] initWithDictionary:[aDecoder decodeObjectForKey:@"json"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.JSON forKey:@"json"];
}

@end
