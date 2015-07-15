//
//  SKFilter.h
//  SnapchatKit
//
//  Created by Tanner on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"

@interface SKFilter : SKThing

@property (nonatomic, readonly) NSString  *identifier;
@property (nonatomic, readonly) NSInteger priority;

/** Array of CLLocation objects. */
@property (nonatomic, readonly) NSArray   *coordinates;
@property (nonatomic, readonly) NSString  *geofenceIdentifier;

@property (nonatomic, readonly) BOOL      hideSponsoredSlug;
/** Whether the filter is animated or not. */
@property (nonatomic, readonly) BOOL      isDynamic;
/** Whether the story is sponsored. */
@property (nonatomic, readonly) BOOL      isSponsored;
@property (nonatomic, readonly) NSURL     *imageURL;

/** Array of strings such as "scale_aspect_fit" and "bottom" indicating where the filter should be positioned. */
@property (nonatomic, readonly) NSArray   *position;
@property (nonatomic, readonly) BOOL      prepositioned;
@property (nonatomic, readonly) NSURL     *prepositionedImageURL;

@end
