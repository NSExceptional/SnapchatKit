//
//  SKLocation.h
//  SnapchatKit
//
//  Created by Tanner on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"

@interface SKLocation : SKThing

/** An array of \c SKFilter objects. */
@property (nonatomic, readonly) NSArray      *filters;
/** Undocumented */
@property (nonatomic, readonly) NSDictionary *weather;
/** Undocumented */
@property (nonatomic, readonly) NSArray      *ourStoryAuths;
/** Undocumented */
@property (nonatomic, readonly) NSArray      *preCacheGeofilters;

@end
