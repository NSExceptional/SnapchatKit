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

@class SKSnapOptions, CLLocation;


@interface SKClient (Snaps)

/** Sends a snap with the given options.
 @param blob The \c SKBlob object containing the image or video data to send. Can be created with any \c NSData object.
 @param options The options for the snap to be sent.
 @param completion Takes an error, if any, and an \c SKSnapResponse object. */
- (void)sendSnap:(SKBlob *)blob options:(SKSnapOptions *)options completion:(ResponseBlock)completion;
/** Sends a snap to everyone in \c recipients with text \c text for \c duration seconds.
 @param blob The \c SKBlob object containing the image or video data to send. Can be created with any \c NSData object.
 @param recipients An array of username strings.
 @param text The text to label the snap with. This text is not superimposed upon the image; you must do that yourself.
 @param duration The legnth of the snap. It must be greater than \c 0 or an exception will be raised.
 @param completion Takes an error, if any, and an \c SKSnapResponse object. */
- (void)sendSnap:(SKBlob *)blob to:(NSArray *)recipients text:(NSString *)text timer:(NSTimeInterval)duration completion:(ResponseBlock)completion;

/** Marks a snap as opened for \c secondsViewed seconds.
 @param secondsViewed The number of seconds the snap was viewed for.
 @param completion Takes an error, if any. */
- (void)markSnapViewed:(SKSnap *)snap for:(CGFloat)secondsViewed completion:(ErrorBlock)completion;
/** Marks a set of snaps as opened for the specified length at the given times.
 @param snaps An array of \c SKSnap objects.
 @param times An array of \c NSDate objects.
 @param secondsViewed An array of \c NSNumber objects. Try to use floating point nubmers. */
- (void)markSnapsViewed:(NSArray *)snaps atTimes:(NSArray *)times for:(NSArray *)secondsViewed completion:(ErrorBlock)completion;
/** Marks a snap as screenshotted and viewed for \c secondsViewed seconds.
 @param secondsViewed The number of seconds the snap was viewed for.
 @param completion Takes an error, if any. */
- (void)markSnapScreenshot:(SKSnap *)snap for:(NSUInteger)secondsViewed completion:(ErrorBlock)completion;

/** Loads a snap.
 @param completion Takes an error, if any, and an \c SKBlob object. */
- (void)loadSnap:(SKSnap *)snap completion:(ResponseBlock)completion;

/** Loads filters for a location.
 @param completion Takes an error, if any, and an \c SKLocation object. */
- (void)loadFiltersForLocation:(CLLocation *)location completion:(ResponseBlock)completion;

@end
