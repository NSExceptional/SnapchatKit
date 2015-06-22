//
//  SKStoryUpdater.m
//  SnapchatKit
//
//  Created by Tanner on 6/16/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKStoryUpdater.h"
#import "SKStory.h"

#import "NSString+SnapchatKit.h"

@implementation SKStoryUpdater

+ (instancetype)viewedStory:(SKStory *)story at:(NSDate *)date screenshots:(NSUInteger)sscount {
    NSParameterAssert([story isKindOfClass:[SKStory class]]);
    return [[self alloc] initWithStoryIdentifier:story.identifier viewedOn:date sscount:sscount];
}

- (id)initWithStoryIdentifier:(NSString *)identifier viewedOn:(NSDate *)date sscount:(NSUInteger)sscount {
    NSParameterAssert(identifier);
    self = [super init];
    if (self) {
        _storyID         = identifier;
        _timestamp       = [NSString timestampFrom:date];
        _screenshotCount = sscount;
    }
    
    return self;
}

@end
