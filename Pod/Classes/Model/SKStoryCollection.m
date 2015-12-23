//
//  SKStoryCollection.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKStoryCollection.h"
#import "SKStory.h"

@implementation SKStoryCollection

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username=%@, NSFW=%d count=%lu> stories=%@",
            NSStringFromClass(self.class), self.username, self.matureContent, (unsigned long)self.stories.count, self.stories];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"username": @"username",
             @"matureContent": @"mature_content",
             @"adPlacementData": @"ad_placement_metadata",
             @"displayName": @"display_name",
             @"sharedIdentifier": @"shared_id",
             @"isLocal": @"is_local",
             @"viewedThumbnail": @"thumbnails.viewed.url",
             @"unviewedThumbnail": @"thumbnails.unviewed.url",
             @"viewedThumbnailNeedsAuth": @"thumbnails.viewed.needs_auth",
             @"unviewedThumbnailNeedsAuth": @"thumbnails.unviewed.needs_auth",
             @"stories": @"stories"};
}

MTLTransformPropertyURL(viewedThumbnail)
MTLTransformPropertyURL(unviewedThumbnail)

+ (NSValueTransformer *)storiesJSONTransformer { return [self sk_modelArrayTransformerForClass:[SKStory class]]; }

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKStoryCollection class]])
        return [self isEqualToStoryCollection:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToStoryCollection:(SKStoryCollection *)collection {
    return [self.username isEqualToString:collection.username];
}

- (NSUInteger)hash {
    return self.username.hash;
}

- (BOOL)isSharedStory {
    return [self.stories[0] shared];
}

@end
