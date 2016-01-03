//
//  SKClient+Account.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient+Account.h"
#import "SKRequest.h"
#import "SKBlob.h"
#import "SKUser.h"
#import "SKTrophy.h"
#import "SKTrophyMetrics.h"
#import "SKAvatar.h"

#import "NSArray+SnapchatKit.h"
#import "NSDictionary+SnapchatKit.h"
#import "NSString+SnapchatKit.h"
#import "SKClient+Friends.h"

@implementation SKClient (Account)

- (void)handleCallback:(NSDictionary *)json error:(NSError *)error callback:(ErrorBlock)completion {
    if (!error && [json[@"logged"] boolValue]) {
        completion(nil);
    } else {
        completion(error ?: [SKRequest errorWithMessage:json.description code:1]);
    }
}

- (void)updateBestFriendsCount:(NSUInteger)number completion:(ErrorBlock)completion {
    if (number < 3) number = 3;
    if (number > 7) number = 7;
    
    [self postTo:SKEPAccount.setBestsCount query:@{@"num_best_friends": @(number), @"username": self.username} callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            [self.currentSession.bestFriendUsernames removeAllObjects];
            [self.currentSession.bestFriendUsernames addObjectsFromArray:json[@"best_friends"]];
            if (completion)
                completion(nil);
        } else {
            if (completion)
                completion(error);
        }
    }];
}

- (void)updateSnapPrivacy:(SKSnapPrivacy)privacy completion:(ErrorBlock)completion {
    privacy = MIN(privacy, 1);
    NSDictionary *query = @{@"action": @"updatePrivacy",
                            @"privacySetting": @(privacy),
                            @"username": self.username};
    [self postTo:SKEPAccount.settings query:query callback:^(NSDictionary *json, NSError *error) {
        [self handleCallback:json error:error callback:completion];
    }];
}

- (void)updateStoryPrivacy:(SKStoryPrivacy)privacy hideFrom:(NSArray *)friends completion:(ErrorBlock)completion {
    NSDictionary *query = @{@"action": @"updateStoryPrivacy",
                            @"privacySetting": SKStringFromStoryPrivacy(privacy),
                            @"storyFriendsToBlock": friends.JSONString,
                            @"username": self.username};
    [self postTo:SKEPAccount.settings query:query callback:^(NSDictionary *json, NSError *error) {
        [self handleCallback:json error:error callback:completion];
    }];
}

- (void)updateEmail:(NSString *)address completion:(ErrorBlock)completion {
    NSParameterAssert(address);
    NSDictionary *query = @{@"action": @"updateEmail",
                            @"email": address,
                            @"username": self.username};
    [self postTo:SKEPAccount.settings query:query callback:^(NSDictionary *json, NSError *error) {
        [self handleCallback:json error:error callback:completion];
    }];
}

- (void)updateSearchableByNumber:(BOOL)searchable completion:(ErrorBlock)completion {
    NSDictionary *query = @{@"action": @"updateSearchableByPhoneNumber",
                            @"searchable": @(searchable),
                            @"username": self.username};
    [self postTo:SKEPAccount.settings query:query callback:^(NSDictionary *json, NSError *error) {
        [self handleCallback:json error:error callback:completion];
    }];
}

- (void)updateNotificationSoundSetting:(BOOL)enableSound completion:(ErrorBlock)completion {
    NSDictionary *query = @{@"action": @"updateNotificationSoundSetting",
                            @"notificationSoundSetting": enableSound ? @"ON" : @"OFF",
                            @"username": self.username};
    [self postTo:SKEPAccount.settings query:query callback:^(NSDictionary *json, NSError *error) {
        [self handleCallback:json error:error callback:completion];
    }];
}

- (void)updateDisplayName:(NSString *)displayName completion:(ErrorBlock)completion {
    [self updateDisplayNameForUser:self.username newName:displayName completion:completion];
}


- (void)updateFeatureSettings:(NSDictionary *)settings completion:(ErrorBlock)completion {
    NSParameterAssert(settings.allKeys.count < 10);
    if (!settings.allKeys.count) {
        if (completion)
            completion(nil);
        return;
    }
    
    NSDictionary *features = @{SKFeatureSettings.travelMode:          settings[SKFeatureSettings.travelMode]          ?: @(self.currentSession.enableTravelMode),
                               SKFeatureSettings.barcodeEnabled:      settings[SKFeatureSettings.barcodeEnabled]      ?: @NO,
                               SKFeatureSettings.smartFilters:        settings[SKFeatureSettings.smartFilters]        ?: @(self.currentSession.enableSmartFilters),
                               SKFeatureSettings.payReplaySnaps:      settings[SKFeatureSettings.payReplaySnaps]      ?: @(self.currentSession.payReplaySnaps),
                               SKFeatureSettings.lensStoreEnabled:    settings[SKFeatureSettings.lensStoreEnabled]    ?: @(self.currentSession.lensStoreEnabled),
                               SKFeatureSettings.visualFilters:       settings[SKFeatureSettings.visualFilters]       ?: @(self.currentSession.enableVisualFilters),
                               SKFeatureSettings.prefetchLensStore:   settings[SKFeatureSettings.prefetchLensStore]   ?: @(self.currentSession.prefetchStoreLensesEnabled),
                               SKFeatureSettings.QRCodeEnabled:       settings[SKFeatureSettings.QRCodeEnabled]       ?: @(self.currentSession.QRCodeEnabled),
                               SKFeatureSettings.scrambleBestFriends: settings[SKFeatureSettings.scrambleBestFriends] ?: @NO};
    
    NSDictionary *query = @{@"settings": features.JSONString,
                            @"username": self.username};
    [self postTo:SKEPUpdate.featureSettings query:query callback:^(id object, NSError *error) {
        completion(error);
    }];
}

- (void)downloadSnaptagAsSVG:(BOOL)svg completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *query = @{@"image": self.currentSession.QRPath,
                            @"type": svg ? @"SVG" : @"PNG",
                            @"username": self.username};
    [self downloadSnaptagWithParams:query svg:svg completion:completion];
}

- (void)downloadSnaptagForUser:(SKUser *)user asSVG:(BOOL)svg completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *query = @{@"username": self.username,
                            @"type": svg ? @"SVG" : @"PNG",
                            @"username_snapcode": user.username,
                            @"user_id": user.userIdentifier};
    [self downloadSnaptagWithParams:query svg:svg completion:^(id object, NSError *error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:object options:0 error:&jsonError];
            if (!jsonError) {
                NSString *base64data = json[@"imageData"];
                completion(base64data.base64DecodedData, nil);
            } else {
                completion(nil, jsonError);
            }
        } else {
            completion(nil, error);
        }
    }];
}

- (void)downloadSnaptagWithParams:(NSDictionary *)params svg:(BOOL)svg completion:(ResponseBlock)completion {
    [self postTo:SKEPAccount.snaptag query:params response:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                    if (data.length) {
                        if (!svg)
                            completion(svg ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : data, nil);
                    } else {
                        completion(nil, [SKRequest errorWithMessage:@"Error retrieving snaptag" code:1]);
                    }
                }
            } else {
                completion(nil, error);
            }
        });
    }];
}

- (void)uploadAvatar:(NSArray *)datas completion:(ErrorBlock)completion {
    NSParameterAssert(datas);
    
    NSDictionary *query = @{@"username": self.username,
                            @"data": [SKAvatar avatarDataFromImageDatas:datas]};
    // SKEPAccount.avatar.set
    // multipart/form-data; takes a single "data" parameter in addition to the usual "username" param
    [self postTo:SKEPAccount.avatar.set query:query callback:^(id object, NSError *error) {
        completion(error);
    }];
}

- (void)downloadAvatar:(NSString *)username size:(SKAvatarSize)size completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *query = @{@"username": self.username,
                            @"size": SKStringFromAvatarSize(size),
                            @"added_friends": @[username].JSONString};
    [self downloadAvatarWithEndpoint:SKEPAccount.avatar.getFriend params:query completion:completion];
}

- (void)downloadYourAvatar:(SKAvatarSize)size completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *query = @{@"username": self.username,
                            @"size": SKStringFromAvatarSize(size),
                            @"username_image": self.username};
    [self downloadAvatarWithEndpoint:SKEPAccount.avatar.get params:query completion:completion];
}

- (void)downloadAvatarWithEndpoint:(NSString *)endpoint params:(NSDictionary *)params completion:(ResponseBlock)completion {
    [self postTo:endpoint query:params response:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSInteger code = [(NSHTTPURLResponse *)response statusCode];
                
                if (code == 200) {
                    if (data.length) {
                        NSError *avError = nil;
                        completion([SKAvatar avatarWithData:data error:&avError], avError);
                    } else {
                        completion(nil, [SKRequest errorWithMessage:@"Error downloading avatar" code:code]);
                    }
                } else if ([(NSHTTPURLResponse *)response statusCode] == 204) {
                    completion(nil, nil);
                }
            } else {
                completion(nil, error);
            }
        });
    }];
}

- (void)removeYourAvatar:(ErrorBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *query = @{@"username": self.username,
                            @"last_updated": [NSString timestamp]};
    [self postTo:SKEPAccount.avatar.remove query:query callback:^(NSDictionary *json, NSError *error) {
        completion(error);
    }];
}

- (void)updateTOSAgreementStatus:(BOOL)snapcash snapcashV2:(BOOL)snapcashV2 square:(BOOL)square completion:(ErrorBlock)completion {
    NSString *acceptSnapCashTos   = snapcash   ? @"true": @"false";
    NSString *acceptSnapCashV2Tos = snapcashV2 ? @"true": @"false";
    NSString *acceptSquareTos     = square     ? @"true": @"false";
    
    NSDictionary *agreements = @{@"snapcash_new_tos_accepted": acceptSnapCashTos,
                                 @"snapcash_tos_v2_accepted": acceptSnapCashV2Tos,
                                 @"square_tos_accepted": acceptSquareTos};
    NSDictionary *query = @{@"username": self.username,
                            @"client_properties": agreements.JSONString};
    [self postTo:SKEPUpdate.user query:query callback:^(NSDictionary *json, NSError *error) {
        completion(error);
    }];
}

- (void)getTrophies:(ArrayBlock)completion {
    NSParameterAssert(completion);
    [self updateTrophiesWithMetrics:nil completion:^(NSError *error) {
        if (!error) {
            completion(self.currentSession.trophyCase, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)updateTrophiesWithMetrics:(SKTrophyMetrics *)metrics completion:(ErrorBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *counters = metrics.metrics ?: @{};
    NSDictionary *query = @{@"username": self.username, @"metric_counters": counters};
    [self postTo:SKEPUpdate.trophies query:query callback:^(NSDictionary *json, NSError *error) {
        if (!error) {
            NSArray *trophies = json[@"response"];
            trophies = [MTLJSONAdapter modelsOfClass:[SKTrophy class] fromJSONArray:trophies error:nil];
            [self.currentSession setValue:trophies forKey:@"trophyCase"];
            completion(nil);
        } else {
            completion(error);
        }
    }];
}

@end
