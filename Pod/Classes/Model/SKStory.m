//
//  SKStory.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKStory.h"
#import "SKClient+Stories.h"

@implementation SKStory

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ shared=%d, zipped=%d, auth=%d, viewed=%d, duration=%lu, text=%@, time left=%lu>",
            NSStringFromClass(self.class), self.shared, self.zipped, self.needsAuth, self.viewed, (unsigned long)self.duration, self.text, (unsigned long)self.timeLeft];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"author": @"story.username",
             @"viewed": @"viewed",
             @"shared": @"story.is_shared",
             @"zipped": @"story.zipped",
             @"matureContent": @"story.mature_content",
             @"needsAuth": @"story.needs_auth",
             @"duration": @"story.time",
             @"identifier": @"story.id",
             @"text": @"story.caption_text_display",
             @"clientIdentifier": @"story.client_id",
             @"storyFilterIdentifier": @"story.story_filter_id",
             @"adCanFollow": @"story.ad_can_follow",
             @"mediaIdentifier": @"story.media_id",
             @"mediaIV": @"story.media_iv",
             @"mediaKey": @"story.media_key",
             @"mediaKind": @"story.media_type",
             @"mediaURL": @"story.media_url",
             @"thumbIV": @"story.thumbnail_iv",
             @"thumbURL": @"story.thumbnail_url",
             @"timeLeft": @"story.time_left",
             @"created": @"story.timestamp",
             @"submissionIdentifier": @"story.submission_id",
             @"unlockables": @"story.unlockables"};
}

MTLTransformPropertyURL(mediaURL)
MTLTransformPropertyURL(thumbURL)
MTLTransformPropertyDate(created)

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKStory class]])
        return [self isEqualToStory:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToStory:(SKStory *)story {
    return [story.identifier isEqualToString:self.identifier];
}

- (NSUInteger)hash {
    return self.identifier.hash;
}

@end

@implementation SKStory (SKClient)

- (void)load:(ErrorBlock)completion {
    NSParameterAssert(completion);
    [[SKClient sharedClient] loadStoryBlob:self completion:^(SKBlob *blob, NSError *error) {
        if (!error) {
            _blob = blob;
            completion(nil);
        } else {
            completion(error);
        }
    }];
}

- (void)loadThumbnail:(ErrorBlock)completion {
    NSParameterAssert(completion);
    [[SKClient sharedClient] loadStoryThumbnailBlob:self completion:^(SKBlob *blob, NSError *error) {
        if (!error) {
            _thumbnailBlob = blob;
            completion(nil);
        } else {
            completion(error);
        }
    }];
}

- (NSString *)suggestedFilename {
    if (!self.blob)
        return nil;
    if (self.blob.isImage)
        return [NSString stringWithFormat:@"%@.jpg", self.identifier];
    else if (self.blob.overlay)
        return self.identifier;
    else
        return [NSString stringWithFormat:@"%@.mp4", self.identifier];
}

@end