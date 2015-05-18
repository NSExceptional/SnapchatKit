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
        _viewDate     = [NSDate dateWithTimeIntervalSince1970:[json[@"timestamp"] doubleValue]];
        _screenshot   = [json[@"screenshotted"] boolValue];
        _storyPointer = json[@"storypointer"];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ viewer=%@, screenshot=%hhd>",
            NSStringFromClass(self.class), self.viewer, self.screenshot];
}

@end
