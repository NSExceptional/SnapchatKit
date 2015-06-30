//
//  SKStoryOptions.m
//  SnapchatKitTests
//
//  Created by Harry Gulliford on 30/06/2015.
//  Copyright (c) 2015 Harry Gulliford. All rights reserved.
//

#import "SKStoryOptions.h"

@implementation SKStoryOptions

+ (instancetype)storyWithText:(NSString *)text timer:(NSTimeInterval)timer {
    SKStoryOptions *options = [self new];
    options.text            = text;
    options.timer           = timer;
    return options;
}

- (id)init {
    self = [super init];
    if (self) {
        _text = @"";
        _timer = 3;
    }
    
    return self;
}

- (void)setText:(NSString *)text {
    _text = text ?: @"";
}

- (void)setTimer:(NSTimeInterval)timer {
    NSParameterAssert(timer > 0);
    _timer = timer;
}

@end
