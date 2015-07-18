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
#import "SKUser.h"
#import "SKUserStory.h"
#import "SKStoryUpdater.h"
#import "SKStoryOptions.h"
#import "SKSharedStoryDescription.h"

#import "SKRequest.h"
#import "NSString+SnapchatKit.h"
#import "NSArray+SnapchatKit.h"

@implementation SKClient (Stories)

- (void)postStory:(SKBlob *)blob for:(NSTimeInterval)duration completion:(ErrorBlock)completion {
    SKStoryOptions *options = [SKStoryOptions storyWithText:nil timer:duration];
    [self postStory:blob options:options completion:completion];
}

- (void)postStory:(SKBlob *)blob options:(SKStoryOptions *)options completion:(ErrorBlock)completion {
    NSParameterAssert(blob); NSParameterAssert(options);
    
    [self uploadStory:blob completion:^(NSString *mediaID, NSError *error) {
        if (!error) {
            NSDictionary *query = @{@"caption_text_display": options.text,
                                    @"story_timestamp":      [NSString timestamp],
                                    @"type":                 blob.isImage ? @(SKMediaKindImage) : @(SKMediaKindVideo),
                                    @"media_id":             mediaID,
                                    @"client_id":            mediaID,
                                    @"time":                 @((NSUInteger)options.timer),
                                    @"username":             self.username,
                                    @"camera_front_facing":  @(options.cameraFrontFacing),
                                    @"my_story":             @"true",
                                    @"zipped":               @0,
                                    @"shared_ids":           @"{}"};
            [self postTo:SKEPStories.post query:query callback:^(NSDictionary *json, NSError *sendError) {
                completion(sendError);
            }];
        } else {
            completion(error);
        }
    }];
}

- (void)uploadStory:(SKBlob *)blob completion:(ResponseBlock)completion {
    NSString *uuid = SKMediaIdentifier(self.username);
    
    NSDictionary *query = @{@"media_id": uuid,
                            @"type": blob.isImage ? @(SKMediaKindImage) : @(SKMediaKindVideo),
                            @"data": blob.data,
                            @"zipped": @0,
                            @"features_map": @"{}",
                            @"username": self.username};
    NSDictionary *headers = @{SKHeaders.clientAuthToken: [NSString stringWithFormat:@"Bearer %@", self.googleAuthToken],
                              SKHeaders.contentType: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", SKConsts.boundary]};
    
    [SKRequest postTo:SKEPStories.upload query:query headers:headers token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:error data:data response:response completion:^(id object, NSError *error) {
                if (!error) {
                    completion(uuid, nil);
                } else {
                    completion(nil, error);
                }
            }];
        });
    }];
}

- (void)loadStoryBlob:(SKStory *)story completion:(ResponseBlock)completion {
    NSParameterAssert(story); NSParameterAssert(completion);
    // I was using this, but... [NSString stringWithFormat:@"%@%@", kepGetStoryBlob, story.mediaIdentifier]
    if (story.needsAuth) {
        NSDictionary *query = @{@"story_id": story.mediaIdentifier, @"username": self.username};
        [SKRequest postTo:SKEPStories.authBlob query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSInteger code = [(NSHTTPURLResponse *)response statusCode];
                if (code == 200) {
                    [SKBlob blobWithStoryData:data forStory:story completion:^(SKBlob *storyBlob, NSError *blobError) {
                        if (!blobError) {
                            completion(storyBlob, nil);
                        } else {
                            completion(nil, blobError);
                        }
                    }];
                } else {
                    [self handleError:error data:data response:response completion:completion];
                }
            }
        }];
    } else {
        [self get:[story.mediaURL.absoluteString stringByReplacingOccurrencesOfString:SKConsts.baseURL withString:@""] callback:^(NSData *data, NSError *error) {
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
}

- (void)loadStoryThumbnailBlob:(SKStory *)story completion:(ResponseBlock)completion {
    NSParameterAssert(story); NSParameterAssert(completion);
    [self get:[NSString stringWithFormat:@"%@%@", SKEPStories.thumb, story.mediaIdentifier] callback:^(NSData *data, NSError *error) {
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
    [self postTo:SKEPStories.remove query:query callback:^(id object, NSError *error) {
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
    [self postTo:SKEPUpdate.stories query:query callback:^(NSDictionary *json, NSError *error) {
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
    [self postTo:SKEPFriends.hide query:query callback:^(NSDictionary *json, NSError *error) {
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

- (void)getSharedDescriptionForStory:(SKUser *)sharedStory completion:(ResponseBlock)completion {
    NSParameterAssert(sharedStory.sharedStoryIdentifier); NSParameterAssert(completion);
    
    [self get:[NSString stringWithFormat:@"shared/description?ln=en&shared_id=%@", sharedStory.sharedStoryIdentifier] callback:^(NSData *data, NSError *error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError)
                completion([[SKSharedStoryDescription alloc] initWithDictionary:json], nil);
            else
                completion(nil, jsonError);
        } else {
            completion(nil, error);
        }
    }];
}

@end