//
//  SKClient+Snaps.m
//  SnapchatKit
//
//  Created by Tanner on 5/26/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient+Snaps.h"
#import "SKRequest.h"

#import "NSString+SnapchatKit.h"

@implementation SKClient (Snaps)

- (void)markSnapViewed:(NSString *)identifier for:(NSUInteger)secondsViewed completion:(BooleanBlock)completion {
    NSDictionary *snapInfo = @{identifier: @{@"t":@([[NSString timestamp] integerValue]),
                                             @"sv": @(secondsViewed)}};
    NSDictionary *viewed = @{@"eventName": @"SNAP_VIEW",
                             @"params": @{@"id":identifier},
                             @"ts": @(([[NSString timestamp] integerValue]/1000) - secondsViewed)};
    NSDictionary *expire = @{@"eventName": @"SNAP_EXPIRED",
                             @"params": @{@"id":identifier},
                             @"ts": @([[NSString timestamp] integerValue]/1000)};
    NSArray *events = @[viewed, expire];
    [self sendEvents:events data:snapInfo completion:completion];
}


@end
