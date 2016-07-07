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

#import "SnapchatKit-Constants.h"
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
    NSParameterAssert(blob); NSParameterAssert(options); NSParameterAssert(completion);
    
    [self uploadSnap:blob completion:^(NSString *mediaID, NSError *error) {
        if (!error) {
            NSDictionary *params = @{@"camera_front_facing": @(options.cameraFrontFacing),
                                     @"country_code":        self.currentSession.countryCode,
                                     @"media_id":            mediaID,
                                     @"recipients":          options.recipients.recipientsString,
                                     @"recipient_ids":       options.recipients.recipientsString,
                                     @"reply":               @(options.isReply),
                                     @"time":                @((NSUInteger)options.timer),
                                     @"zipped":              blob.zipData ? @1 : @0,
                                     @"username":            self.username};
            [self postWith:params to:SKEPSnaps.send callback:^(TBResponseParser *parser) {
                completion(parser.error ? nil : [[SKSnapResponse alloc] initWithDictionary:parser.JSON], parser.error);
            }];
        } else {
            completion(nil, error);
        }
    }];
}

- (void)uploadSnap:(SKBlob *)blob completion:(ResponseBlock)completion {
    NSString *uuid = SKMediaIdentifier(self.username);
    
    NSDictionary *params = @{@"media_id": uuid,
                             @"type": blob.isImage ? @(SKMediaKindImage) : @(SKMediaKindVideo),
                             
                             @"zipped": blob.zipData ? @1 : @0,
                             @"features_map": @"{}",
                             @"username": self.username};
    
    [self post:^(TBURLRequestBuilder *make, NSDictionary *bodyForm) {
        make.multipartData(@{@"data": blob.zipData ? blob.zipData : blob.data});
        make.multipartStrings(MergeDictionaries(params, bodyForm));
    } to:SKEPSnaps.upload callback:^(TBResponseParser *parser) {
        completion(parser.error ? nil : uuid, parser.error);
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
    
    [self sendEvents:@[viewed, expire] data:snapInfo completion:completion];
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
    
    NSDictionary *params = @{@"added_friends_timestamp": [NSString timestampFrom:self.currentSession.addedFriendsTimestamp],
                             @"json": json.JSONString, @"username": self.username};
    [self postWith:params to:SKEPUpdate.snaps callback:^(TBResponseParser *parser) {
        TBRunBlockP(completion, params.objectEnumerator);
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
    
    [self sendEvents:@[screenshot] data:snapInfo completion:completion];
}

- (void)loadSnap:(SKSnap *)snap completion:(ResponseBlock)completion {
    NSParameterAssert([snap isKindOfClass:[SKSnap class]]);
    [self loadSnapWithIdentifier:snap.identifier completion:completion];
}

- (void)loadSnapWithIdentifier:(NSString *)identifier completion:(ResponseBlock)completion {
    NSParameterAssert(identifier); NSParameterAssert(completion);
    
    NSDictionary *params = @{@"id": identifier, @"username": self.username};
    [self postWith:params to:SKEPSnaps.loadBlob callback:^(TBResponseParser *parser) {
        // Did get snap
        if (parser.response.statusCode == 200) {
            // Unzipped
            if (parser.data.isJPEG || parser.data.isMPEG4) {
                SKBlob *blob = [SKBlob blobWithData:parser.data];
                if (blob) {
                    completion(blob, nil);
                } else {
                    NSString *message = @"Error initializing blob with data";
                    completion(nil, [TBResponseParser error:message domain:@"SnapchatKit" code:parser.response.statusCode]);
                }
            }
            // Needs to be unzipped
            else if (parser.data.isCompressed) {
                NSString *path  = [SKTempDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"sk-zip~%@.tmp", identifier]];
                NSString *unzip = [SKTempDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"sk~%@.tmp", identifier]];
                [parser.data writeToFile:path atomically:YES];
                
                [SSZipArchive unzipFileAtPath:path toDestination:unzip completion:^(NSString *path, BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        SKBlob *blob = [SKBlob blobWithContentsOfPath:unzip];
                        if (blob) {
                            completion(blob, nil);
                        } else {
                            completion(nil, error ?: [TBResponseParser error:@"Unknown error unarchiving blob" domain:@"SnapchatKit" code:1]);
                        }
                    } else {
                        SKLog(@"%@", error);
                        completion(nil, error);
                    }
                }];
                
            } else if (parser.data) {
                SKBlob *blob = [SKBlob blobWithData:parser.data];
                if (blob) {
                    NSString *message = [NSString stringWithFormat:@"Unknown blob format: %@", parser.contentType];
                    completion(blob, [TBResponseParser error:message domain:@"SnapchatKit" code:parser.response.statusCode]);
                } else {
                    completion(nil, [TBResponseParser error:@"Error initializing blob with data" domain:@"SnapchatKit" code:1]);
                }
            } else {
                NSString *message = [NSString stringWithFormat:@"Error retrieving snap: %@", identifier];
                completion(nil, [TBResponseParser error:message domain:@"SnapchatKit" code:parser.response.statusCode]);
            }
            // Failed to get snap
        } else {
            completion(nil, parser.error);
        }
    }];
}

- (void)loadFiltersForLocation:(CLLocation *)location completion:(ResponseBlock)completion {
    NSParameterAssert(location); NSParameterAssert(completion);
    
    NSDictionary *params = @{@"lat": @(location.coordinate.latitude),
                             @"long": @(location.coordinate.longitude),
                             @"screen_height": @(self.screenSize.height),
                             @"screen_width": @(self.screenSize.width),
                             @"username": self.username};
    [self postWith:params to:SKEPMisc.locationData callback:^(TBResponseParser *parser) {
        if (parser.JSON[@"location"]) {
            completion([[SKLocation alloc] initWithDictionary:parser.JSON[@"location"]], nil);
        } else {
            completion(nil, parser.error);
        }
    }];
}

@end
