//
//  SKSnapOptions.m
//  SnapchatKit
//
//  Created by Tanner on 6/16/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSnapOptions.h"

@implementation SKSnapOptions

+ (instancetype)sendTo:(NSArray *)recipients text:(NSString *)text for:(NSTimeInterval)timer {
    SKSnapOptions *options = [self new];
    options.recipients     = recipients;
    options.text           = text;
    options.timer          = timer;
    return options;
}

- (id)init {
    self = [super init];
    if (self) {
        _recipients = @[];
        _text       = @"";
        _timer      = 3;
    }
    
    return self;
}

- (void)setRecipients:(NSArray *)recipients {
    NSParameterAssert(recipients.count);
    _recipients = recipients;
//    for (NSString *r in recipients)
//        NSParameterAssert([r isKindOfClass:[NSString class]]);
}

- (void)setText:(NSString *)text {
    _text = text ?: @"";
}

- (void)setTimer:(NSTimeInterval)timer {
    NSParameterAssert(timer > 0);
    _timer = timer;
}

@end
