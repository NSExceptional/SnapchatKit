//
//  SKLocation.h
//  SnapchatKit
//
//  Created by Tanner on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"

@interface SKLocation : SKThing

@property (nonatomic, readonly) NSArray *filters;
@property (nonatomic, readonly) NSDictionary *weather;
@property (nonatomic, readonly) NSArray *ourStoryAuths;
@property (nonatomic, readonly) NSArray *preCacheGeofilters;

@end
