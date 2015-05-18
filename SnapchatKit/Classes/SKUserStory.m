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
    self = [super initWithDictionary:json];
    NSDictionary *extras     = json[@"story_extras"];
    NSDictionary *storyNotes = json[@"story_notes"];
    
    if (self) {
        _screenshotCount = [extras[@"screenshot_count"] integerValue];
        _viewCount       = [extras[@"view_count"] integerValue];
        
        NSMutableArray *notes = [NSMutableArray new];
        for (NSDictionary *note in storyNotes)
            [notes addObject:[[SKStoryNote alloc] initWithDictionary:note]];
        
        _notes = notes;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ screenshots=%lu, views=%lu, notes=%lu>%@",
            NSStringFromClass(self.class), (unsigned long)self.screenshotCount, (unsigned long)self.viewCount, (unsigned long)self.notes.count, [super description]];
}

@end
