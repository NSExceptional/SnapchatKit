//
//  SKUserStory.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKUserStory.h"
#import "SKStoryNote.h"

@implementation SKUserStory

- (id)initWithDictionary:(NSDictionary *)json {
    NSDictionary *extras     = json[@"story_extras"];
    NSDictionary *storyNotes = json[@"story_notes"];
    
    // I merge these dictionaries with the rest of
    // the JSON so that unknownJSONKeys is more thorough.
    if (kDebugJSON) {
        NSMutableDictionary *fullJSON = json.mutableCopy;
        [fullJSON addEntriesFromDictionary:extras];
        fullJSON[@"story_extras"] = @{};
        json = fullJSON;
    }
    
    self = [super initWithDictionary:json];
    if (self) {
        _screenshotCount = [extras[@"screenshot_count"] integerValue];
        _viewCount       = [extras[@"view_count"] integerValue];
        
        NSMutableArray *notes = [NSMutableArray new];
        for (NSDictionary *note in storyNotes)
            [notes addObject:[[SKStoryNote alloc] initWithDictionary:note]];
        
        _notes = notes;
    }
    
    [[self class] addKnownJSONKeys:@[@"story_extras", @"story_notes", @"viewed", @"screenshot_count", @"view_count"]];
    
    return self;
}

@end
