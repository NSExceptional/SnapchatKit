//
//  SKClient+Snaps.h
//  SnapchatKit
//
//  Created by Tanner on 5/26/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKClient.h"
#import "SKSnap.h"

#import <CoreLocation/CLLocation.h>
@class SKSnapOptions;


@interface SKClient (Snaps)

/** @c blob can be created with any @c NSData object. */
- (void)sendSnap:(SKBlob *)blob options:(SKSnapOptions *)options completion:(ErrorBlock)completion;
/** @c duration must be greater than @c 9. @note @c text is not actually put into the image, that's your job. @c blob can be created with any @c NSData object. */
- (void)sendSnap:(SKBlob *)blob to:(NSArray *)recipients text:(NSString *)text timer:(NSTimeInterval)duration completion:(ErrorBlock)completion;

- (void)markSnapViewed:(SKSnap *)snap for:(NSUInteger)secondsViewed completion:(ErrorBlock)completion;
- (void)markSnapScreenshot:(SKSnap *)snap for:(NSUInteger)secondsViewed completion:(ErrorBlock)completion;

/** callback takes an SKBlob object. */
- (void)loadSnap:(SKSnap *)snap completion:(ResponseBlock)completion;

/** Callback takes an SKLocation object. */
- (void)loadFiltersForLocation:(CLLocation *)location completion:(ResponseBlock)completion;

@end

@interface SKSnap (Networking)
/** callback takes an SKBlob object. */
- (void)loadMediaWithCompletion:(ResponseBlock)completion;
@end