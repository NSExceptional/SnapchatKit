//
//  SKClient+Stories.h
//  SnapchatKit
//
//  Created by Tanner Bennett on 6/13/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKClient.h"
#import "SKBlob.h"

@class SKStory, SKUserStory, SKStoryCollection, SKStoryOptions;


@interface SKClient (Stories)

/** Posts a story with the given options.
 @param blob The \c SKBlob object containing the image or video data to send. Can be created with any \c NSData object.
 @param options The options for the story to post.
 @param completion Takes an error, if any. */
- (void)postStory:(SKBlob *)blob options:(SKStoryOptions *)options completion:(ErrorBlock)completion;
/** Posts a story with the given options.
 @param blob The \c SKBlob object containing the image or video data to send. Can be created with any \c NSData object.
 @param duration The length of the story. This value is ignored for video snaps.
 @param completion Takes an error, if any.
 @note Assumes camera not front facing. */
- (void)postStory:(SKBlob *)blob for:(NSTimeInterval)duration completion:(ErrorBlock)completion;

/** Downloads media for a story.
 @param story The story to download.
 @param completion Takes an error, if any, and an \c SKBlob object. */
- (void)loadStoryBlob:(SKStory *)story completion:(ResponseBlock)completion;
/** Downloads the thumbnail for a story.
 @param story The story whose thumbnail you wish to download.
 @param completion Takes an error, if any, and an \c SKBlob object. */
- (void)loadStoryThumbnailBlob:(SKStory *)story completion:(ResponseBlock)completion;

/** Batch loads media for a set of stories.
 @param stories An array of \c SKStory objects whose media you wish to download.
 @param completion Takes an error, if any, an array of \c SKStory objects with initialized \c blob properties, and an array of \c SKStory objects that could not be retrieved, if any. */
- (void)loadStories:(NSArray *)stories completion:(CollectionResponseBlock)completion;

/** Deletes a story of yours.
 @param completion Takes an error, if any. */
- (void)deleteStory:(SKUserStory *)story completion:(ErrorBlock)completion;

/** Marks a set of stories as opened.
 @param stories An array of \c SKStoryUpdater objects.
 @param completion Takes an error, if any. */
- (void)markStoriesViewed:(NSArray *)stories completion:(ErrorBlock)completion;
/** Marks a single story opened.
 @discussion To batch mark stories viewed, use \c -markStoriesViewed:completion:.
 @param story The story to mark as opened.
 @param sscount The number of times the story was screenshotted.
 @param completion Takes an error, if any. */
- (void)markStoryViewed:(SKStory *)story screenshotCount:(NSUInteger)sscount completion:(ErrorBlock)completion;

/** Hides a shared story from the story feed.
 @param completion Takes an error, if any. */
- (void)hideSharedStory:(SKStoryCollection *)story completion:(ErrorBlock)completion;

/** I forget what this is for. Does nothing if the story is not a shared story.
 @param sharedStory A shared story.
 @param completion Takes an error, if any. */
- (void)provideSharedDescription:(SKStory *)sharedStory completion:(ErrorBlock)completion;

/** Retrieves the description for a shared story.
 @param sharedStory A shared story.
 @param completion Takes an error, if any, and an \c SKSharedStoryDescription object. */
- (void)getSharedDescriptionForStory:(SKUser *)sharedStory completion:(ResponseBlock)completion;

@end
