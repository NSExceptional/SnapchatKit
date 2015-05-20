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
    NSParameterAssert(json);
    
    self = [super init];
    if (self) {
        _JSON = json;
        _knownJSONKeys = [NSMutableArray new];
    }
    
    return self;
}

- (NSArray *)unknownJSONKeys {
    if (_unknownJSONKeys)
        return _unknownJSONKeys;
    
    NSMutableArray *temp = [NSMutableArray new];
    NSArray *allKeys     = self.JSON.allKeys;
    for (NSString *key in self.knownJSONKeys)
        if (![allKeys containsObject:key])
            [temp addObject:key];
    
    _unknownJSONKeys = temp;
    
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
