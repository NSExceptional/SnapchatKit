//
//  SKUserStory.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKUserStory.h"
#import "SKStoryNote.h"

@implementation SKUserStory

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"screenshotCount": @"story_extras.screenshot_count",
              @"viewCount": @"story_extras.view_count",
              @"notes": @"story_notes"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

+ (NSValueTransformer *)notesJSONTransformer { return [self sk_modelArrayTransformerForClass:[SKStoryNote class]]; }

@end
