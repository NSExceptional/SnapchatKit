//
//  SKUser.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKUser.h"

@implementation SKUser

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@sees your stories=%d, is shared=%d, is local=%d, status=%@, username=%@>",
            NSStringFromClass(self.class), _canSeeCustomStories, _isSharedStory, _isLocalStory, @(self.friendStatus), self.username];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"friendmojiString": @"friendmoji_string",
              @"friendmojiTypes": @"friendmoji_symbols",
              @"venue": @"venue",
              @"snapStreakCount": @"snap_streak_count",
              @"sharedStoryIdentifier": @"shared_story_id",
              @"canSeeCustomStories": @"can_see_custom_stories",
              @"needsLove": @"needs_love",
              @"isSharedStory": @"is_shared_story",
              @"isLocalStory": @"local_story",
              @"hasCustomDescription": @"has_custom_description",
              @"decayThumbnail": @"dont_decay_thumbnail",
              @"timestamp": @"ts"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

MTLTransformPropertyDate(timestamp)
MTLTransformPropertyDate(expiration)

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKUser class]])
        return [self isEqualToUser:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToUser:(SKUser *)user {
    return [self.friendmojiString isEqualToString:user.friendmojiString] && [super isEqual:user];
}

@end
