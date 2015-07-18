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

@synthesize unknownJSONKeys = _unknownJSONKeys;

- (id)initWithDictionary:(NSDictionary *)json {
    NSParameterAssert(json.allKeys.count > 0);
    
    self = [super init];
    if (self) {
        _JSON = json;
        _knownJSONKeys = [NSMutableSet new];
    }
    
    return self;
}

- (NSArray *)unknownJSONKeys {
    if (_unknownJSONKeys)
        return _unknownJSONKeys;
    
    NSMutableSet *unknown = [NSMutableSet setWithArray:self.JSON.allKeys];
    [unknown minusSet:self.knownJSONKeys];
    _unknownJSONKeys = unknown.allObjects;
    
    return _unknownJSONKeys;
}

#pragma mark NSCoding protocol

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [[self.class alloc] initWithDictionary:[aDecoder decodeObjectForKey:@"json"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.JSON forKey:@"json"];
}


@end
