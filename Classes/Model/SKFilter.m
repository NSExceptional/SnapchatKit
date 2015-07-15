//
//  SKFilter.m
//  SnapchatKit
//
//  Created by Tanner on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKFilter.h"

#import <CoreLocation/CLLocation.h>

@implementation SKFilter

- (id)initWithDictionary:(NSDictionary *)json {
    NSParameterAssert(json);
    
    self = [super initWithDictionary:json];
    if (self) {
        _identifier            = json[@"filter_id"];
        _priority              = [json[@"priority"] integerValue];
        _hideSponsoredSlug     = [json[@"hide_sponsored_slug"] boolValue];
        _imageURL              = [NSURL URLWithString:json[@"image"]];
        _isDynamic             = [json[@"is_dynamic_geofilter"] boolValue];
        _isSponsored           = [json[@"is_sponsored"] boolValue];
        _position              = json[@"position"];
        _prepositioned         = [json[@"prepositioned"] boolValue];
        _prepositionedImageURL = [NSURL URLWithString:json[@"prepositioned_image"]];

        NSDictionary *geofence = json[@"geofence"];
        NSArray *coords        = geofence[@"coordinates"];
        _geofenceIdentifier    = geofence[@"id"];
        
        NSMutableArray *locations = [NSMutableArray array];
        for (NSDictionary *loc in coords)
            [locations addObject:[[CLLocation alloc] initWithLatitude:[loc[@"lat"] doubleValue] longitude:[loc[@"long"] doubleValue]]];
        
        _coordinates = locations;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ dynamic=%d, sponsored=%d, priority=%ld image=%@>",
            NSStringFromClass(self.class), self.isDynamic, self.isSponsored, (long)self.priority, self.imageURL.absoluteString];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKFilter class]])
        return [self isEqualToFilter:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToFilter:(SKFilter *)filter {
    return [filter.identifier isEqualToString:self.identifier];
}

- (NSUInteger)hash {
    return self.identifier.hash;
}

@end
