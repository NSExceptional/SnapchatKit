//
//  SKClient+Snaps.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/26/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient+Snaps.h"
#import "SKRequest.h"
#import "SKBlob.h"
#import "SKLocation.h"
#import "SKSnapOptions.h"
#import "SKSnapResponse.h"

#import "NSDictionary+SnapchatKit.h"
#import "NSString+SnapchatKit.h"
#import "NSArray+SnapchatKit.h"
#import "NSData+SnapchatKit.h"
#import "SSZipArchive.h"

#import <CoreLocation/CLLocation.h>

@implementation SKClient (Snaps)

// TODO: pass back snap objects

- (void)sendSnap:(SKBlob *)blob to:(NSArray *)recipients text:(NSString *)text timer:(NSTimeInterval)duration completion:(ResponseBlock)completion {
    SKSnapOptions *options = [SKSnapOptions new];
    options.recipients = recipients;
    options.text = text;
    options.timer = duration;
    [self sendSnap:blob options:options completion:completion];
}

- (void)sendSnap:(SKBlob *)blob options:(SKSnapOptions *)options completion:(ResponseBlock)completion {
    NSParameterAssert(blob); NSParameterAssert(options);
    
    [self uploadSnap:blob completion:^(NSString *mediaID, NSError *error) {
        if (!error) {
            NSDictionary *query = @{@"camera_front_facing": @(options.cameraFrontFacing),
                                    @"country_code":        self.currentSession.countryCode,
                                    @"media_id":            mediaID,
                                    @"recipients":          options.recipients.recipientsString,
                                    @"recipient_ids":       options.recipients.recipientsString,
                                    @"reply":               @(options.isReply),
                                    @"time":                @((NSUInteger)options.timer),
                                    @"zipped":              blob.zipData ? @1 : @0,
                                    @"username":            self.username};
            [self postTo:SKEPSnaps.send query:query callback:^(NSDictionary *json, NSError *sendError) {
                if (!sendError) {
                    completion([[SKSnapResponse alloc] initWithDictionary:json], nil);
                } else {
                    completion(nil, sendError);
                }
            }];
        } else {
            completion(nil, error);
        }
    }];
}

- (void)uploadSnap:(SKBlob *)blob completion:(ResponseBlock)completion {
    NSString *uuid = SKMediaIdentifier(self.username);
    
    NSDictionary *query = @{@"media_id": uuid,
                            @"type": blob.isImage ? @(SKMediaKindImage) : @(SKMediaKindVideo),
                            @"data": blob.zipData ? blob.zipData : blob.data,
                            @"zipped": blob.zipData ? @1 : @0,
                            @"features_map": @"{}",
                            @"username": self.username};

    [self postTo:SKEPSnaps.upload query:query callback:^(id object, NSError *error) {
        completion(error ? nil : uuid, error);
    }];
}

// TODO: add random offset to secondsViewed

- (void)old_markSnapViewed:(SKSnap *)snap for:(NSUInteger)secondsViewed completion:(ErrorBlock)completion {
    NSDictionary *snapInfo = @{snap.identifier: @{@"t":@([[NSString timestamp] integerValue]),
                                                  @"sv": @(secondsViewed*1000)}};
    NSDictionary *viewed   = @{@"eventName": @"SNAP_VIEW",
                               @"params":    @{@"id":snap.identifier},
                               @"ts":        @(([[NSString timestamp] integerValue]/1000) - secondsViewed)};
    NSDictionary *expire   = @{@"eventName": @"SNAP_EXPIRED",
                               @"params":    @{@"id":snap.identifier},
                               @"ts":        @([[NSString timestamp] integerValue]/1000)};
    NSArray *events = @[viewed, expire];
    [self sendEvents:events data:snapInfo completion:completion];
}

- (void)markSnapViewed:(SKSnap *)snap for:(CGFloat)secondsViewed replay:(BOOL)replayed completion:(ErrorBlock)completion {
    [self markSnapsViewed:@[snap] atTimes:@[[NSDate date]] for:@[@(secondsViewed)] replayed:@[@(replayed)] completion:completion];
}

- (void)markSnapsViewed:(NSArray *)snaps atTimes:(NSArray *)timestamps for:(NSArray *)secondsViewed replayed:(NSArray *)replayed completion:(ErrorBlock)completion {
    NSParameterAssert(snaps.count == timestamps.count && timestamps.count == secondsViewed.count);
    
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    SKSnap *snap; NSString *ts; NSNumber *num, *replay;
    for (NSUInteger i = 0; i < snaps.count; i++) {
        snap   = snaps[i];
        ts     = [NSString timestampFrom:timestamps[i]];
        num    = secondsViewed[i];
        replay = @([replayed[i] integerValue]); // necessary because replayed by itself will print "true" or "false" and we want 1 or 0
        json[snap.identifier] = @{@"t": ts, @"sv": num, @"es_id": snap.esIdentifier, @"replayed": replay, @"stack_id": @""};
    }
    
    NSDictionary *query = @{@"added_friends_timestamp": [NSString timestampFrom:self.currentSession.addedFriendsTimestamp],
                            @"json": json.JSONString, @"username": self.username};
    [self postTo:SKEPUpdate.snaps query:query callback:^(id object, NSError *error) {
        if (completion) completion(error);
    }];
}

- (void)markSnapScreenshot:(SKSnap *)snap for:(NSUInteger)secondsViewed completion:(ErrorBlock)completion {
    NSParameterAssert(snap);
    
    NSDictionary *snapInfo   = @{snap.identifier: @{@"t":@([[NSString timestamp] integerValue]),
                                                    @"sv": @(secondsViewed),
                                                    @"c": @(SKSnapStatusScreenshot)}};
    NSDictionary *screenshot = @{@"eventName": @"SNAP_SCREENSHOT",
                                 @"params":    @{@"id":snap.identifier},
                                 @"ts":        @([[NSString timestamp] integerValue]/1000)};
    NSArray *events = @[screenshot];
    [self sendEvents:events data:snapInfo completion:completion];
}

- (void)loadSnap:(SKSnap *)snap completion:(ResponseBlock)completion {
    NSParameterAssert([snap isKindOfClass:[SKSnap class]]);
    [self loadSnapWithIdentifier:snap.identifier completion:completion];
}

- (void)loadSnapWithIdentifier:(NSString *)identifier completion:(ResponseBlock)completion {
    NSParameterAssert(identifier); NSParameterAssert(completion);
    
    NSDictionary *query = @{@"id": identifier, @"username": self.username};
    [self postTo:SKEPSnaps.loadBlob query:query response:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Did get snap
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            // Unzipped
            if ([data isJPEG] || [data isMPEG4]) {
                SKBlob *blob = [SKBlob blobWithData:data];
                if (blob)
                    completion(blob, nil);
                else
                    completion(nil, [SKRequest errorWithMessage:@"Error initializing blob with data" code:1]);
                
            // Needs to be unzipped
            } else if ([data isCompressed]) {
                NSString *path  = [SKTempDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"sk-zip~%@.tmp", identifier]];
                NSString *unzip = [SKTempDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"sk~%@.tmp", identifier]];
                [data writeToFile:path atomically:YES];
                
                [SSZipArchive unzipFileAtPath:path toDestination:unzip completion:^(NSString *path, BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        SKBlob *blob = [SKBlob blobWithContentsOfPath:unzip];
                        if (blob)
                            completion(blob, nil);
                        else
                            completion(nil, [SKRequest errorWithMessage:@"Error initializing blob" code:2]);
                    } else {
                        SKLog(@"%@", error);
                    }
                }];
                
            } else if (data) {
                SKBlob *blob = [SKBlob blobWithData:data];
                if (blob)
                    completion(blob, [SKRequest errorWithMessage:@"Unknown blob format" code:[(NSHTTPURLResponse *)response statusCode]]);
                else
                    completion(nil, [SKRequest errorWithMessage:@"Error initializing blob with data" code:1]);
            } else {
                completion(nil, [SKRequest errorWithMessage:[NSString stringWithFormat:@"Error retrieving snap: %@", identifier] code:[(NSHTTPURLResponse *)response statusCode]]);
            }
        // Failed to get snap
        } else {
            completion(nil, [SKRequest errorWithMessage:@"Unknown error" code:[(NSHTTPURLResponse *)response statusCode]]);
        }
    }];
}

- (void)loadFiltersForLocation:(CLLocation *)location completion:(ResponseBlock)completion {
    NSParameterAssert(location); NSParameterAssert(completion);
    
    NSDictionary *query = @{@"lat": @(location.coordinate.latitude),
                            @"long": @(location.coordinate.longitude),
                            @"screen_height": @(self.screenSize.height),
                            @"screen_width": @(self.screenSize.width),
                            @"username": self.username};
    [self postTo:SKEPMisc.locationData query:query callback:^(NSDictionary *json, NSError *error) {
        if (json[@"location"]) {
            completion([[SKLocation alloc] initWithDictionary:json[@"location"]], nil);
        }
    }];
}

@end
