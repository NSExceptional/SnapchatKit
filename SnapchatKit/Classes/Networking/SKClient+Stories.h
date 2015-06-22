//
//  SKClient+Stories.h
//  SnapchatKit
//
//  Created by Tanner on 6/13/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKClient.h"

@class SKStory, SKUserStory, SKStoryCollection;


@interface SKClient (Stories)

/** Callback takes an @c SKBlob object. */
- (void)loadStoryBlob:(SKStory *)story completion:(ResponseBlock)completion;
/** Callback takes an @c SKBlob object. */
- (void)loadStoryThumbnailBlob:(SKStory *)story completion:(ResponseBlock)completion;

/** Callback takes an array of @c SKStory objects with initialized @c blob properties, and an array of @c SKStory objects that could not be retrieved, if any. */
- (void)loadStories:(NSArray *)stories completion:(CollectionResponseBlock)completion;

/** Callback may be nil. */
- (void)deleteStory:(SKUserStory *)story completion:(ErrorBlock)completion;

/** @param stories An array of @c SKStoryUpdater objects. */
- (void)markStoriesViewed:(NSArray *)stories completion:(ErrorBlock)completion;
/** To batch mark stories viewed, use @c -markStoriesViewed:completion: */
- (void)markStoryViewed:(SKStory *)story screenshotCount:(NSUInteger)sscount completion:(ErrorBlock)completion;

- (void)hideSharedStory:(SKStoryCollection *)story completion:(ErrorBlock)completion;

/** Does nothing if the story is not a shared story. */
- (void)provideSharedDescription:(SKStory *)sharedStory completion:(ErrorBlock)completion;

@end
