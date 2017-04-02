//
//  SKFilter.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKFilter.h"

#import "NSArray+SnapchatKit.h"
#import <CoreLocation/CLLocation.h>

@implementation SKFilter

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ dynamic=%d, sponsored=%d, priority=%ld image=%@>",
            NSStringFromClass(self.class), self.isDynamic, self.isSponsored, (long)self.priority, self.imageURL.absoluteString];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"identifier": @"filter_id",
             @"priority": @"priority",
             @"hideSponsoredSlug": @"hide_sponsored_slug",
             @"imageURL": @"image",
             @"isDynamic": @"is_dynamic_geofilter",
             @"isSponsored": @"is_sponsored",
             @"position": @"position",
             @"prepositioned": @"prepositioned",
             @"prepositionedImageURL": @"prepositioned_image",
             @"geofenceIdentifier": @"geofence.id",
             @"coordinates": @"geofence.coordinates"};
}

MTLTransformPropertyURL(imageURL)
MTLTransformPropertyURL(prepositionedImageURL)

+ (NSValueTransformer *)coordinatesJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *coords, BOOL *success, NSError *__autoreleasing *error) {
        NSMutableArray *locations = [NSMutableArray array];
        for (NSDictionary *loc in coords)
            [locations addObject:[[CLLocation alloc] initWithLatitude:[loc[@"lat"] doubleValue] longitude:[loc[@"long"] doubleValue]]];
        return locations.copy;
    } reverseBlock:^id(NSArray *locations, BOOL *success, NSError *__autoreleasing *error) {
        return locations.dictionaryValues;
    }];
}

#pragma mark - Equality

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
