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

#import "SnapchatKit-Constants.h"
#import "SKClient+Friends.h"

@implementation SKClient (Account)

- (void)handleCallback:(TBResponseParser *)parser callback:(ErrorBlock)completion {
    if (!parser.error) {
        if (![parser.JSON[@"logged"] boolValue]) {
            NSLog(@"%@", parser.JSON);
        }
        completion(nil);
    } else {
        completion(parser.error);
    }
}

- (void)updateBestFriendsCount:(NSUInteger)number completion:(ErrorBlock)completion {
    if (number < 3) number = 3;
    if (number > 7) number = 7;
    
    NSDictionary *params = @{@"num_best_friends": @(number), @"username": self.username};
    [self postWith:params to:SKEPAccount.setBestsCount callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            [self.currentSession.bestFriendUsernames removeAllObjects];
            [self.currentSession.bestFriendUsernames addObjectsFromArray:parser.JSON[@"best_friends"]];
            TBRunBlockP(completion, nil);
        } else {
            TBRunBlockP(completion, parser.error);
        }
    }];
}

- (void)updateSnapPrivacy:(SKSnapPrivacy)privacy completion:(ErrorBlock)completion {
    privacy = MIN(privacy, 1);
    NSDictionary *params = @{@"action": @"updatePrivacy",
                             @"privacySetting": @(privacy),
                             @"username": self.username};
    [self postWith:params to:SKEPAccount.settings callback:^(TBResponseParser *parser) {
        [self handleCallback:parser callback:completion];
    }];
}

- (void)updateStoryPrivacy:(SKStoryPrivacy)privacy hideFrom:(NSArray *)friends completion:(ErrorBlock)completion {
    NSDictionary *params = @{@"action": @"updateStoryPrivacy",
                             @"privacySetting": SKStringFromStoryPrivacy(privacy),
                             @"storyFriendsToBlock": friends.JSONString,
                             @"username": self.username};
    [self postWith:params to:SKEPAccount.settings callback:^(TBResponseParser *parser) {
        [self handleCallback:parser callback:completion];
    }];
}

- (void)updateEmail:(NSString *)address completion:(ErrorBlock)completion {
    NSParameterAssert(address);
    NSDictionary *params = @{@"action": @"updateEmail",
                             @"email": address,
                             @"username": self.username};
    [self postWith:params to:SKEPAccount.settings callback:^(TBResponseParser *parser) {
        [self handleCallback:parser callback:completion];
    }];
}

- (void)updateSearchableByNumber:(BOOL)searchable completion:(ErrorBlock)completion {
    NSDictionary *params = @{@"action": @"updateSearchableByPhoneNumber",
                             @"searchable": @(searchable),
                             @"username": self.username};
    [self postWith:params to:SKEPAccount.settings callback:^(TBResponseParser *parser) {
        [self handleCallback:parser callback:completion];
    }];
}

- (void)updateNotificationSoundSetting:(BOOL)enableSound completion:(ErrorBlock)completion {
    NSDictionary *params = @{@"action": @"updateNotificationSoundSetting",
                             @"notificationSoundSetting": enableSound ? @"ON" : @"OFF",
                             @"username": self.username};
    [self postWith:params to:SKEPAccount.settings callback:^(TBResponseParser *parser) {
        [self handleCallback:parser callback:completion];
    }];
}

- (void)updateDisplayName:(NSString *)displayName completion:(ErrorBlock)completion {
    [self updateDisplayNameForUser:self.username newName:displayName completion:completion];
}


- (void)updateFeatureSettings:(NSDictionary *)settings completion:(ErrorBlock)completion {
    NSParameterAssert(settings.allKeys.count < 10);
    if (!settings.allKeys.count) {
        TBRunBlockP(completion, nil);
        return;
    }
    
    NSDictionary *features = @{SKFeatureSettings.travelMode: @(self.currentSession.enableTravelMode),
                               SKFeatureSettings.barcodeEnabled: @NO,
                               SKFeatureSettings.smartFilters: @(self.currentSession.enableSmartFilters),
                               SKFeatureSettings.payReplaySnaps: @(self.currentSession.payReplaySnaps),
                               SKFeatureSettings.lensStoreEnabled: @(self.currentSession.lensStoreEnabled),
                               SKFeatureSettings.visualFilters: @(self.currentSession.enableVisualFilters),
                               SKFeatureSettings.prefetchLensStore: @(self.currentSession.prefetchStoreLensesEnabled),
                               SKFeatureSettings.QRCodeEnabled: @(self.currentSession.QRCodeEnabled),
                               SKFeatureSettings.scrambleBestFriends: @NO};
    features = [features dictionaryByReplacingValuesForKeys:settings];
    
    NSDictionary *params = @{@"settings": features.JSONString,
                             @"username": self.username};
    [self postWith:params to:SKEPUpdate.featureSettings callback:^(TBResponseParser *parser) {
        completion(parser.error);
    }];
}

- (void)downloadSnaptagAsSVG:(BOOL)svg completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *params = @{@"image": self.currentSession.QRPath,
                             @"type": svg ? @"SVG" : @"PNG",
                             @"username": self.username};
    [self downloadSnaptagWithParams:params svg:svg completion:completion];
}

// TODO: look into this, why was I passing svg (possibly YES) if I'm just going to decode JSON?
- (void)downloadSnaptagForUser:(SKUser *)user asSVG:(BOOL)svg completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *params = @{@"username": self.username,
                             @"type": svg ? @"SVG" : @"PNG",
                             @"username_snapcode": user.username,
                             @"user_id": user.userIdentifier};
    [self downloadSnaptagWithParams:params svg:NO completion:^(NSDictionary *json, NSError *error) {
        if (!error) {
            NSString *base64data = json[@"imageData"];
            completion(base64data.base64DecodedData, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)downloadSnaptagWithParams:(NSDictionary *)params svg:(BOOL)svg completion:(ResponseBlock)completion {
    [self postWith:params to:SKEPAccount.snaptag callback:^(TBResponseParser *parser) {
        if (!parser.error && parser.response.statusCode == 200 && parser.data.length) {
            if (!svg) {
                completion(svg ? (parser.text ?: [NSString stringWithCString:parser.data.bytes encoding:4]) : parser.JSON, nil);
            }
        } else {
            NSUInteger code = parser.response.statusCode;
            completion(nil, parser.error ?: [TBResponseParser error:@"Error retrieving snaptag" domain:@"SnapchatKit" code:code]);
        }
    }];
}

- (void)uploadAvatar:(NSArray *)datas completion:(ErrorBlock)completion {
    NSParameterAssert(datas);
    
    NSDictionary *params = @{@"username": self.username,
                             @"data": [SKAvatar avatarDataFromImageDatas:datas]};
    // SKEPAccount.avatar.set
    // multipart/form-data; takes a single "data" parameter in addition to the usual "username" param
    [self post:^(TBURLRequestBuilder *make, NSDictionary *bodyForm) {
        make.multipartStrings(MergeDictionaries(@{@"username": self.username}, bodyForm));
        make.multipartData(@{@"data": [SKAvatar avatarDataFromImageDatas:datas]});
    } to:SKEPAccount.avatar.set callback:^(TBResponseParser *parser) {
        completion(parser.error);
    }];
}

- (void)downloadAvatar:(NSString *)username size:(SKAvatarSize)size completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *params = @{@"username": self.username,
                             @"size": SKStringFromAvatarSize(size),
                             @"added_friends": @[username].JSONString};
    [self downloadAvatarWithEndpoint:SKEPAccount.avatar.getFriend params:params completion:completion];
}

- (void)downloadYourAvatar:(SKAvatarSize)size completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *params = @{@"username": self.username,
                             @"size": SKStringFromAvatarSize(size),
                             @"username_image": self.username};
    [self downloadAvatarWithEndpoint:SKEPAccount.avatar.get params:params completion:completion];
}

- (void)downloadAvatarWithEndpoint:(NSString *)endpoint params:(NSDictionary *)params completion:(ResponseBlock)completion {
    [self postWith:params to:endpoint callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            if (parser.response.statusCode == 200) {
                if (parser.data.length) {
                    NSError *avError = nil;
                    completion([SKAvatar avatarWithData:parser.data error:&avError], avError);
                } else {
                    NSUInteger code = parser.response.statusCode;
                    completion(nil, [TBResponseParser error:@"Error downloading avatar" domain:@"SnapchatKit'" code:code]);
                }
            } else if (parser.response.statusCode == TBHTTPStatusCodeNoContent) {
                completion(nil, nil);
            }
        } else {
            completion(nil, parser.error);
        }
    }];
}

- (void)removeYourAvatar:(ErrorBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *params = @{@"username": self.username,
                             @"last_updated": [NSString timestamp]};
    [self postWith:params to:SKEPAccount.avatar.remove callback:^(TBResponseParser *parser) {
        completion(parser.error);
    }];
}

- (void)updateTOSAgreementStatus:(BOOL)snapcash snapcashV2:(BOOL)snapcashV2 square:(BOOL)square completion:(ErrorBlock)completion {
    NSString *acceptSnapCashTos   = snapcash   ? @"true": @"false";
    NSString *acceptSnapCashV2Tos = snapcashV2 ? @"true": @"false";
    NSString *acceptSquareTos     = square     ? @"true": @"false";
    
    NSDictionary *agreements = @{@"snapcash_new_tos_accepted": acceptSnapCashTos,
                                 @"snapcash_tos_v2_accepted": acceptSnapCashV2Tos,
                                 @"square_tos_accepted": acceptSquareTos};
    NSDictionary *params = @{@"username": self.username,
                             @"client_properties": agreements.JSONString};
    [self postWith:params to:SKEPUpdate.user callback:^(TBResponseParser *parser) {
        completion(parser.error);
    }];
}

- (void)getTrophies:(ArrayBlock)completion {
    NSParameterAssert(completion);
    [self updateTrophiesWithMetrics:nil completion:^(NSError *error) {
        completion(error ? self.currentSession.trophyCase : nil, error);
    }];
}

- (void)updateTrophiesWithMetrics:(SKTrophyMetrics *)metrics completion:(ErrorBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *counters = metrics.metrics ?: @{};
    NSDictionary *params = @{@"username": self.username, @"metric_counters": counters};
    [self postWith:params to:SKEPUpdate.trophies callback:^(TBResponseParser *parser) {
        if (!parser.error) {
            NSArray *trophies = parser.JSON[@"response"];
            trophies = [MTLJSONAdapter modelsOfClass:[SKTrophy class] fromJSONArray:trophies error:nil];
            [self.currentSession setValue:trophies forKey:@"trophyCase"];
            completion(nil);
        } else {
            completion(parser.error);
        }
    }];
}

@end
