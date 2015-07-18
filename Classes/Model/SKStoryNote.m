//
//  SKStoryNote.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKStoryNote.h"

@implementation SKStoryNote

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    if (self) {
        _viewer       = json[@"viewer"];
        _viewDate     = [NSDate dateWithTimeIntervalSince1970:[json[@"timestamp"] doubleValue]/1000];
        _screenshot   = [json[@"screenshotted"] boolValue];
        _storyPointer = json[@"storypointer"];
    }
    
    [[self class] addKnownJSONKeys:@[@"viewer", @"timestamp", @"screenshotted", @"storypointer"]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ viewer=%@, screenshot=%d>",
            NSStringFromClass(self.class), self.viewer, self.screenshot];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKStoryNote class]])
        return [self isEqualToStoryNote:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToStoryNote:(SKStoryNote *)storyNote {
    return [self.viewer isEqualToString:storyNote.viewer] && [self.viewDate isEqualToDate:storyNote.viewDate];;
}

@end
