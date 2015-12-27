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
    NSParameterAssert(settings.allKeys.count < 9);
    if (!settings.allKeys.count) {
        if (completion)
            completion(nil);
        return;
    }
    
    NSDictionary *features = @{SKFeatureSettings.frontFacingFlash: settings[SKFeatureSettings.frontFacingFlash] ?: @(self.currentSession.enableFrontFacingFlash),
                               SKFeatureSettings.replaySnaps:      settings[SKFeatureSettings.replaySnaps]      ?: @(self.currentSession.enableReplaySnaps),
                               SKFeatureSettings.smartFilters:     settings[SKFeatureSettings.smartFilters]     ?: @(self.currentSession.enableSmartFilters),
                               SKFeatureSettings.visualFilters:    settings[SKFeatureSettings.visualFilters]    ?: @(self.currentSession.enableVisualFilters),
                               SKFeatureSettings.powerSaveMode:    settings[SKFeatureSettings.powerSaveMode]    ?: @(self.currentSession.enablePowerSaveMode),
                               SKFeatureSettings.specialText:      settings[SKFeatureSettings.specialText]      ?: @(self.currentSession.enableSpecialText),
                               SKFeatureSettings.swipeCashMode:    settings[SKFeatureSettings.swipeCashMode]    ?: @(self.currentSession.enableSwipeCashMode),
                               SKFeatureSettings.travelMode:       settings[SKFeatureSettings.travelMode]       ?: @(self.currentSession.enableTravelMode)};
    
    NSDictionary *query = @{@"settings": features.JSONString,
                            @"username": self.username};
    [self postTo:SKEPUpdate.featureSettings query:query callback:^(id object, NSError *error) {
        completion(error);
    }];
}

- (void)downloadSnaptag:(ResponseBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *query = @{@"image": self.currentSession.QRPath,
                            @"type": @"SVG",
                            @"username": self.username};
    [self postTo:SKEPAccount.snaptag query:query response:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                    if (data.length)
                        completion([SKBlob blobWithData:data], nil);
                    else
                        completion(nil, [SKRequest errorWithMessage:@"Error retrieving snaptag" code:1]);
                }
            } else {
                completion(nil, error);
            }
        });
    }];
}

- (void)uploadAvatar:(NSArray *)datas completion:(ErrorBlock)completion {
    // SKEPAccount.avatar.set
    // multipart/form-data; takes a single "data" parameter in addition to the usual "username" param
}

- (void)downloadAvatar:(NSString *)username completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *query = @{@"username": self.username,
                            @"size": @"MEDIUM",
                            @"username_image": username};
    [self postTo:SKEPAccount.avatar.get query:query response:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                    if (data.length)
                        [[SKBlob blobWithData:data] decompress:completion];
                    else
                        completion(nil, [SKRequest errorWithMessage:@"Error retrieving snaptag" code:1]);
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
    [self postTo:SKEPAccount.avatar.get query:query callback:^(NSDictionary *json, NSError *error) {
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
    
}

@end
