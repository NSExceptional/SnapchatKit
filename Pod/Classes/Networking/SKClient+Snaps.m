//
//  SKClient+Snaps.m
//  SnapchatKit
//
//  Created by Tanner on 5/26/15.
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
                                    @"zipped":              @0,
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
                            @"data": blob.data,
                            @"zipped": @0,
                            @"features_map": @"{}",
                            @"username": self.username};
    NSDictionary *headers = @{SKHeaders.clientAuthToken: [NSString stringWithFormat:@"Bearer %@", self.googleAuthToken],
                              SKHeaders.contentType: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", SKConsts.boundary]};

    [SKRequest postTo:SKEPSnaps.upload query:query headers:headers token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:error data:data response:response completion:^(id object, NSError *error) {
                if (!error) {
                    completion(uuid, nil);
                } else {
                    completion(nil, error);
                }
            }];
        });
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

- (void)markSnapViewed:(SKSnap *)snap for:(CGFloat)secondsViewed completion:(ErrorBlock)completion {
    [self markSnapsViewed:@[snap] atTimes:@[[NSDate date]] for:@[@(secondsViewed)] completion:completion];
}

- (void)markSnapsViewed:(NSArray *)snaps atTimes:(NSArray *)timestamps for:(NSArray *)secondsViewed completion:(ErrorBlock)completion {
    NSParameterAssert(snaps.count == timestamps.count && timestamps.count == secondsViewed.count);
    
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    SKSnap *snap; NSString *ts; NSNumber *num;
    for (NSUInteger i = 0; i < snaps.count; i++) {
        snap = snaps[i];
        ts   = [NSString timestampFrom:timestamps[i]];
        num  = secondsViewed[i];
        json[snap.identifier] = @{@"t": ts, @"sv": num};
    }
    
    NSDictionary *query = @{@"added_friends_timestamp": [NSString timestampFrom:self.currentSession.addedFriendsTimestamp],
                            @"json": json.JSONString, @"username": self.username};
    [self postTo:SKEPUpdate.snaps query:query callback:^(id object, NSError *error) {
        completion(error);
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
    [SKRequest postTo:SKEPSnaps.loadBlob query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
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
