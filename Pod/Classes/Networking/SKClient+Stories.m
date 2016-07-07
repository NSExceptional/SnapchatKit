//
//  SKClient+Stories.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 6/13/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient+Stories.h"
#import "SKStoryCollection.h"
#import "SKStory.h"
#import "SKUser.h"
#import "SKUserStory.h"
#import "SKStoryUpdater.h"
#import "SKStoryOptions.h"
#import "SKSharedStoryDescription.h"

#import "SKRequest.h"
#import "SnapchatKit-Constants.h"


@implementation SKClient (Stories)

- (void)postStory:(SKBlob *)blob for:(NSTimeInterval)duration completion:(ErrorBlock)completion {
    SKStoryOptions *options = [SKStoryOptions storyWithText:nil timer:duration];
    [self postStory:blob options:options completion:completion];
}

- (void)postStory:(SKBlob *)blob options:(SKStoryOptions *)options completion:(ErrorBlock)completion {
    NSParameterAssert(blob); NSParameterAssert(options);
    
    [self uploadStory:blob completion:^(NSString *mediaID, NSError *error) {
        if (!error) {
            NSMutableDictionary *params = @{@"camera_front_facing":  @(options.cameraFrontFacing),
                                            @"client_id":            mediaID,
                                            @"filter_id":            @"",
                                            @"media_id":             mediaID,
                                            @"orientation":          @"0",
                                            @"story_timestamp":      [NSString timestamp],
                                            @"time":                 @((NSUInteger)options.timer),
                                            @"type":                 blob.isImage ? @(SKMediaKindImage) : @(SKMediaKindVideo),
                                            @"username":             self.username,
                                            //                                            @"my_story":             @"true",
                                            @"zipped":               blob.zipData ? @1 : @0}.mutableCopy;
            // Optional parts
            params[@"caption_text_display"] = options.text;
            
            [self post:^(TBURLRequestBuilder *make, NSDictionary *bodyForm) {
                make.multipartData(@{@"thumbnail_data": blob.videoThumbnail});
                make.multipartStrings(MergeDictionaries(params, bodyForm));
            } to:SKEPStories.post callback:^(TBResponseParser *parser) {
                TBRunBlockP(completion, parser.error);
            }];
        } else {
            TBRunBlockP(completion, error);
        }
    }];
}

- (void)uploadStory:(SKBlob *)blob completion:(ResponseBlock)completion {
    NSString *uuid = SKMediaIdentifier(self.username);
    
    NSDictionary *params = @{@"media_id": uuid,
                             @"type": blob.isImage ? @(SKMediaKindImage) : @(SKMediaKindVideo),
                             @"data": blob.zipData ? blob.zipData : blob.data,
                             @"zipped": blob.zipData ? @1 : @0,
                             @"features_map": @"{}",
                             @"username": self.username};
    
    [self postWith:params to:SKEPStories.upload callback:^(TBResponseParser *parser) {
        TBRunBlockP(completion, parser.error ? nil : uuid, parser.error);
    }];
}

- (void)loadStoryBlob:(SKStory *)story completion:(ResponseBlock)completion {
    [self loadStoryOrThumb:story thumbnail:NO completion:completion];
}

- (void)loadStoryThumbnailBlob:(SKStory *)story completion:(ResponseBlock)completion {
    [self loadStoryOrThumb:story thumbnail:YES completion:completion];
}

- (void)loadStoryOrThumb:(SKStory *)story thumbnail:(BOOL)thumbnail completion:(ResponseBlock)completion {
    NSParameterAssert(story); NSParameterAssert(completion);
    
    if (story.needsAuth) {
        NSString *endpoint = thumbnail ? SKEPStories.authThumb : SKEPStories.authBlob;
        NSDictionary *params = @{@"story_id": story.mediaIdentifier, @"username": self.username};
        [self postWith:params to:endpoint callback:^(TBResponseParser *parser) {
            if (!parser.error) {
                [SKBlob blobWithStoryData:parser.data forStory:story isThumb:thumbnail completion:^(SKBlob *storyBlob, NSError *blobError) {
                    completion(blobError ? nil : storyBlob, blobError);
                }];
            } else {
                completion(nil, parser.error);
            }
        }];
    } else {
        
        NSString *url = (thumbnail ? story.thumbURL : story.mediaURL).absoluteString;
        NSString *endpoint = [url stringByReplacingOccurrencesOfString:SKConsts.baseURL withString:@""];
        
        [self get:^(TBURLRequestBuilder *make, NSDictionary *bodyForm) {
            make.baseURL(nil).URL(url).bodyJSONFormString(bodyForm);
        } from:endpoint callback:^(TBResponseParser *parser) {
            if (!parser.error) {
                [SKBlob blobWithStoryData:parser.data forStory:story isThumb:thumbnail completion:^(SKBlob *thumbBlob, NSError *blobError) {
                    completion(blobError ? nil : thumbBlob, blobError);
                }];
            } else {
                completion(nil, parser.error);
            }
        }];
    }
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
    NSDictionary *params = @{@"story_id": story.identifier,
                             @"username": self.username};
    [self postWith:params to:SKEPStories.remove callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            [self.currentSession.userStories removeObject:story];
        }
        TBRunBlockP(completion, parser.error);
    }];
}

- (void)markStoriesViewed:(NSArray *)stories completion:(ErrorBlock)completion {
    NSParameterAssert(stories);
    
    NSMutableArray *friendStories = [NSMutableArray array];
    for (SKStoryUpdater *update in stories)
        [friendStories addObject:@{@"id": update.storyID,
                                   @"screenshot_count": @(update.screenshotCount),
                                   @"timestamp": update.timestamp}];
    
    NSDictionary *params = @{@"username": self.username,
                             @"friend_stories": friendStories.JSONString};
    [self postWith:params to:SKEPUpdate.stories callback:^(TBResponseParser *parser) {
        completion(parser.error);
    }];
}

- (void)markStoryViewed:(SKStory *)story screenshotCount:(NSUInteger)sscount completion:(ErrorBlock)completion {
    NSParameterAssert(story);
    [self markStoriesViewed:@[[SKStoryUpdater viewedStory:story at:[NSDate date] screenshots:sscount]] completion:completion];
}

- (void)hideSharedStory:(SKStoryCollection *)story completion:(ErrorBlock)completion {
    NSParameterAssert(story);
    
    NSDictionary *params = @{@"friend": story.username,
                             @"hide": @"true",
                             @"username": self.username};
    [self postWith:params to:SKEPFriends.hide callback:^(TBResponseParser *parser) {
        completion(parser.error);
    }];
}

- (void)provideSharedDescription:(SKStory *)sharedStory completion:(ErrorBlock)completion {
    NSParameterAssert(sharedStory);
    if (!sharedStory.shared) return;
    
    NSDictionary *params = @{@"shared_id": sharedStory.identifier,
                             @"username": self.username};
    [self postWith:params to:SKEPStories.sharedDescription callback:^(TBResponseParser *parser) {
        completion(parser.error);
    }];
}

- (void)getSharedDescriptionForStory:(SKUser *)sharedStory completion:(ResponseBlock)completion {
    NSParameterAssert(sharedStory.sharedStoryIdentifier); NSParameterAssert(completion);
    
    NSString *endpoint = [NSString stringWithFormat:@"shared/description?ln=en&shared_id=%@", sharedStory.sharedStoryIdentifier];
    [self get:^(TBURLRequestBuilder *make, NSDictionary *bodyForm) {
        make.bodyJSONFormString(bodyForm);
    } from:endpoint callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            completion([[SKSharedStoryDescription alloc] initWithDictionary:parser.JSON], nil);
        } else {
            completion(nil, parser.error);
        }
    }];
}

@end