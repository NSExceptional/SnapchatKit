//
//  SKUser.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKUser.h"

@implementation SKUser

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    if (self) {
        _friendmoji            = json[@"friendmoji_string"];
        _venue                 = json[@"venue"] ?: @"";
        _sharedStoryIdentifier = json[@"shared_story_id"] ?: @"";
        _canSeeCustomStories   = [json[@"can_see_custom_stories"] boolValue];
        _needsLove             = [json[@"needs_love"] boolValue];
        _isSharedStory         = [json[@"is_shared_story"] boolValue];
        _isLocalStory          = [json[@"local_story"] boolValue];
        _hasCustomDescription  = [json[@"has_custom_description"] boolValue];
        _decayThumbnail        = [json[@"dont_decay_thumbnail"] boolValue];
        if (json[@"ts"])
            _timestamp         = [NSDate dateWithTimeIntervalSince1970:[json[@"ts"] doubleValue]/1000];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username=%@, emoji=%@, needs love=%d, sees your stories=%d, is shared=%d, is local=%d>",
            NSStringFromClass(self.class), self.username, self.friendmoji, self.needsLove, self.canSeeCustomStories, self.isSharedStory, self.isLocalStory];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"friendmoji": @"friendmoji_string",
              @"venue": @"venue",
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

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKUser class]])
        return [self isEqualToUser:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToUser:(SKUser *)user {
    return [self.friendmoji isEqualToString:user.friendmoji] && [super isEqual:user];
}

@end
