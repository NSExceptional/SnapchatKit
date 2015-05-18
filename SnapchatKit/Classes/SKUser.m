//
//  SKUser.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
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
        _hasCustomDescription  = [json[@"has_custom_description"] boolValue];
        _decayThumbnail        = [json[@"dont_decay_thumbnail"] boolValue];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username=%@, emoji=%@, needs love=%hhd, sees your stories=%hhd, is live story=%hhd>",
            NSStringFromClass(self.class), self.username, self.friendmoji, self.needsLove, self.canSeeCustomStories, self.isSharedStory];
}

@end
