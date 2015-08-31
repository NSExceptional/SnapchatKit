//
//  SKStoryCollection.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKStoryCollection.h"
#import "SKStory.h"

@implementation SKStoryCollection

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    NSDictionary *thumbs = json[@"thumbnails"];
    if (self) {
        _username        = json[@"username"];
        _matureContent   = [json[@"mature_content"] boolValue];
        _adPlacementData = json[@"ad_placement_metadata"];
        
        _displayName      = json[@"display_name"];
        _sharedIdentifier = json[@"shared_id"];
        _isLocal          = [json[@"is_local"] boolValue];
        
        if (thumbs) {
            _viewedThumbnail        = [NSURL URLWithString:thumbs[@"viewed"][@"url"]];
            _unviewedThumbnail      = [NSURL URLWithString:thumbs[@"unviewed"][@"url"]];
            _viewedThumbNeedsAuth   = [thumbs[@"viewed"][@"needs_auth"] boolValue];
            _unviewedThumbNeedsAuth = [thumbs[@"unviewed"][@"needs_auth"] boolValue];
        }
        
        
        
        NSMutableArray *stories = [NSMutableArray new];
        NSArray *storiesJSON    = json[@"stories"];
        for (NSDictionary *story in storiesJSON)
            [stories addObject:[[SKStory alloc] initWithDictionary:story]];
        
        _stories = stories;
    }
    
    [[self class] addKnownJSONKeys:@[@"username", @"mature_content", @"stories", @"thumbnails", @"ad_placement_metadata", @"display_name", @"is_local", @"shared_id"]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username=%@, NSFW=%d count=%lu> stories=%@",
            NSStringFromClass(self.class), self.username, self.matureContent, (unsigned long)self.stories.count, self.stories];
}

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
