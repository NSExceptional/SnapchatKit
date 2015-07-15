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
    if (self) {
        _username      = json[@"username"];
        _matureContent = [json[@"mature_content"] boolValue];
        
        NSMutableArray *stories = [NSMutableArray new];
        NSArray *storiesJSON    = json[@"stories"];
        for (NSDictionary *story in storiesJSON)
            [stories addObject:[[SKStory alloc] initWithDictionary:story]];
        
        _stories = stories;
    }
    
    [self.knownJSONKeys addObjectsFromArray:@[@"username", @"mature_content", @"stories"]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username=%@, NSFW=%d, stories=\n%@\n>",
            NSStringFromClass(self.class), self.username, self.matureContent, self.stories];
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

@end
