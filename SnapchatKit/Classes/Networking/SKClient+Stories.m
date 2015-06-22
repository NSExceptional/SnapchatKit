//
//  SKClient+Stories.m
//  SnapchatKit
//
//  Created by Tanner on 6/13/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient+Stories.h"
#import "SKStoryCollection.h"
#import "SKStory.h"
#import "SKUserStory.h"
#import "SKBlob.h"
#import "SKStoryUpdater.h"

#import "SKRequest.h"
#import "NSString+SnapchatKit.h"
#import "NSArray+SnapchatKit.h"

@implementation SKClient (Stories)

- (void)loadStoryBlob:(SKStory *)story completion:(ResponseBlock)completion {
    NSParameterAssert(story); NSParameterAssert(completion);
    [self get:[NSString stringWithFormat:@"%@%@", kepGetStoryBlob, story.mediaIdentifier] callback:^(NSData *data, NSError *error) {
        if (!error) {
            [SKBlob blobWithStoryData:data forStory:story completion:^(SKBlob *storyBlob, NSError *blobError) {
                if (!blobError) {
                    completion(storyBlob, nil);
                } else {
                    completion(nil, blobError);
                }
            }];
        } else {
            completion(nil, error);
        }
    }];
}

- (void)loadStoryThumbnailBlob:(SKStory *)story completion:(ResponseBlock)completion {
    NSParameterAssert(story); NSParameterAssert(completion);
    [self get:[NSString stringWithFormat:@"%@%@", kepGetStoryThumb, story.mediaIdentifier] callback:^(NSData *data, NSError *error) {
        if (!error) {
            [SKBlob blobWithStoryData:data forStory:story completion:^(SKBlob *thumbBlob, NSError *blobError) {
                if (!blobError) {
                    completion(thumbBlob, nil);
                } else {
                    completion(nil, blobError);
                }
            }];
        } else {
            completion(nil, error);
        }
    }];
}

- (void)loadStories:(NSArray *)stories completion:(CollectionResponseBlock)completion {
    NSMutableArray *loaded = [NSMutableArray array];
    NSMutableArray *failed = [NSMutableArray array];
    NSMutableArray *errors = [NSMutableArray array];
    
    for (SKStory *story in stories)
        [story load:^(NSError *error) {
            if (!error) {
                [loaded addObject:story];
            } else {
                [errors addObject:error];
                [failed addObject:story];
            }
            
            if (loaded.count + failed.count == stories.count)
                completion(loaded, failed, errors);
        }];
}

- (void)deleteStory:(SKUserStory *)story completion:(ErrorBlock)completion {
    NSParameterAssert(story);
    NSDictionary *query = @{@"story_id": story.identifier,
                            @"username": self.username};
    [self postTo:kepDeleteStory query:query callback:^(id object, NSError *error) {
        if (!error)
            [self.currentSession.userStories removeObject:story];
        completion(error);
    }];
}

- (void)markStoriesViewed:(NSArray *)stories completion:(ErrorBlock)completion {
    NSParameterAssert(stories);
    
    NSMutableArray *friendStories = [NSMutableArray array];
    for (SKStoryUpdater *update in stories)
        [friendStories addObject:@{@"id": update.storyID,
                                   @"screenshot_count": @(update.screenshotCount),
                                   @"timestamp": update.timestamp}];
    
    NSDictionary *query = @{@"username": self.username,
                            @"friend_stories": friendStories.JSONString};
    [self postTo:kepUpdateStories query:query callback:^(NSDictionary *json, NSError *error) {
        completion(error);
    }];
}

- (void)markStoryViewed:(SKStory *)story screenshotCount:(NSUInteger)sscount completion:(ErrorBlock)completion {
    NSParameterAssert(story);
    [self markStoriesViewed:@[[SKStoryUpdater viewedStory:story at:[NSDate date] screenshots:sscount]] completion:completion];
}

- (void)hideSharedStory:(SKStoryCollection *)story completion:(ErrorBlock)completion {
    NSParameterAssert(story);
    
    NSDictionary *query = @{@"friend": story.username,
                            @"hide": @"true",
                            @"username": self.username};
    [self postTo:kepFriendHide query:query callback:^(NSDictionary *json, NSError *error) {
        completion(error);
    }];
}

- (void)provideSharedDescription:(SKStory *)sharedStory completion:(ErrorBlock)completion {
    NSParameterAssert(sharedStory);
    if (!sharedStory.shared) return;
    
    NSDictionary *query = @{@"shared_id": sharedStory.identifier,
                            @"username": self.username};
    [self postTo:kepSharedDescription query:query callback:^(id object, NSError *error) {
        completion(error);
    }];
}

@end