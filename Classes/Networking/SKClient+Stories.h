//
//  SKClient+Stories.h
//  SnapchatKit
//
//  Created by Tanner on 6/13/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKClient.h"
#import "SKBlob.h"

@class SKStory, SKUserStory, SKStoryCollection, SKStoryOptions;


@interface SKClient (Stories)

/** \c blob can be created with any \c NSData object. */
- (void)postStory:(SKBlob *)blob options:(SKStoryOptions *)options completion:(ErrorBlock)completion;
/** \c duration must be greater than \c 0.
 @note \c text is not actually put into the image, that's your job. \c blob can be created with any \c NSData object.
 @note Assumes camera not front facing. */
- (void)postStory:(SKBlob *)blob for:(NSTimeInterval)duration completion:(ErrorBlock)completion;

/** Callback takes an \c SKBlob object. */
- (void)loadStoryBlob:(SKStory *)story completion:(ResponseBlock)completion;
/** Callback takes an \c SKBlob object. */
- (void)loadStoryThumbnailBlob:(SKStory *)story completion:(ResponseBlock)completion;

/** Callback takes an array of \c SKStory objects with initialized \c blob properties, and an array of \c SKStory objects that could not be retrieved, if any. */
- (void)loadStories:(NSArray *)stories completion:(CollectionResponseBlock)completion;

/** Callback may be nil. */
- (void)deleteStory:(SKUserStory *)story completion:(ErrorBlock)completion;

/** @param stories An array of \c SKStoryUpdater objects. */
- (void)markStoriesViewed:(NSArray *)stories completion:(ErrorBlock)completion;
/** To batch mark stories viewed, use \c -markStoriesViewed:completion: */
- (void)markStoryViewed:(SKStory *)story screenshotCount:(NSUInteger)sscount completion:(ErrorBlock)completion;

- (void)hideSharedStory:(SKStoryCollection *)story completion:(ErrorBlock)completion;

/** Does nothing if the story is not a shared story. */
- (void)provideSharedDescription:(SKStory *)sharedStory completion:(ErrorBlock)completion;

@end
