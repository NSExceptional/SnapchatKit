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
    
    [self.knownJSONKeys addObjectsFromArray:@[@"friendmoji_string", @"venue", @"shared_story_id", @"can_see_custom_stories",
                                              @"needs_love", @"is_shared_story", @"has_custom_description", @"dont_decay_thumbnail"]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username=%@, emoji=%@, needs love=%hhd, sees your stories=%hhd, is live story=%hhd>",
            NSStringFromClass(self.class), self.username, self.friendmoji, self.needsLove, self.canSeeCustomStories, self.isSharedStory];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKUser class]])
        return [self isEqualToUser:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToUser:(SKUser *)user {
    return [self.friendmoji isEqualToString:user.friendmoji] && [super isEqual:user];
}

@end
