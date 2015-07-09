//
//  SKLocation.m
//  SnapchatKit
//
//  Created by Tanner on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKLocation.h"
#import "SKFilter.h"

@implementation SKLocation

- (id)initWithDictionary:(NSDictionary *)json {
    NSParameterAssert(json);
    
    NSArray *filters = json[@"filters"];
    
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [NSMutableArray array];
        for (NSDictionary *f in filters)
            [tmp addObject:[[SKFilter alloc] initWithDictionary:f]];
        _filters = tmp;
        
        _weather            = json[@"weather"];
        _ourStoryAuths      = json[@"our_story_auths"];
        _preCacheGeofilters = json[@"pre_cache_geofilters"];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ num filters=%lu>\n%@",
            NSStringFromClass(self.class), (unsigned long)self.filters.count, self.filters];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKLocation class]])
        return [self isEqualToLocation:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToLocation:(SKLocation *)loc {
    if (self.filters.count == loc.filters.count) {
        if (!self.filters.count)
            return [self.weather isEqualToDictionary:loc.weather];
        else
            return [self.filters[0] isEqual:loc.filters[0]];
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [NSString stringWithFormat:@"%lu%lu%lu",
            (unsigned long)self.filters.count,
            (unsigned long)self.ourStoryAuths.count,
            (unsigned long)self.preCacheGeofilters.count].hash;
}

@end
