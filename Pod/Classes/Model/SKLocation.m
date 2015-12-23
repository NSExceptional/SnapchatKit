//
//  SKLocation.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKLocation.h"
#import "SKFilter.h"

@implementation SKLocation

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ num filters=%lu>\n%@",
            NSStringFromClass(self.class), (unsigned long)self.filters.count, self.filters];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"filters": @"filters",
             @"weather": @"weather",
             @"ourStoryAuths": @"our_story_auths",
             @"preCacheGeofilters": @"pre_cache_geofilters"};
}

+ (NSValueTransformer *)weatherJSONTransformer { return [self sk_modelArrayTransformerForClass:[SKFilter class]]; }

#pragma mark - Equality

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
