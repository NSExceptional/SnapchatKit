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
#import "NSData+SnapchatKit.h"
#import "SSZipArchive.h"

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

- (void)loadSnap:(SKSnap *)snap completion:(DataBlock)completion {
    [self loadSnapWithIdentifier:snap.identifier completion:completion];
}

- (void)loadSnapWithIdentifier:(NSString *)identifier completion:(DataBlock)completion {
    NSParameterAssert(identifier); NSParameterAssert(completion);
    
    NSDictionary *query = @{@"id": identifier, @"username": self.username};
    [SKRequest postTo:kepBlob query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Did get snap
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            if ([data isJPEG] || [data isMPEG4]) {
                completion(data, nil);
            } else if (data) {
                completion(data, [SKRequest errorWithMessage:@"Unknown blob format" code:[(NSHTTPURLResponse *)response statusCode]]);
            } else {
                completion(nil, [SKRequest errorWithMessage:[NSString stringWithFormat:@"Error retrieving snap: %@", identifier] code:[(NSHTTPURLResponse *)response statusCode]]);
            }
        // Failed to get snap
        } else {
            completion(nil, [SKRequest errorWithMessage:@"Unknown error" code:[(NSHTTPURLResponse *)response statusCode]]);
        }
    }];
}

@end


@implementation SKSnap (Networking)

- (void)loadMediaWithCompletion:(DataBlock)completion {
    [[SKClient sharedClient] loadSnap:self completion:completion];
}

@end