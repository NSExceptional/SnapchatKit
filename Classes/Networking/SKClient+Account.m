//
//  SKClient+Account.m
//  SnapchatKit
//
//  Created by Tanner on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKClient+Account.h"
#import "SKRequest.h"
#import "SKBlob.h"

#import "NSArray+SnapchatKit.h"
#import "NSDictionary+SnapchatKit.h"
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
    
    [self postTo:kepSetBestCount query:@{@"num_best_friends": @(number), @"username": self.username} callback:^(NSDictionary *json, NSError *error) {
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
    [self postTo:kepSettings query:query callback:^(NSDictionary *json, NSError *error) {
        [self handleCallback:json error:error callback:completion];
    }];
}

- (void)updateStoryPrivacy:(SKStoryPrivacy)privacy hideFrom:(NSArray *)friends completion:(ErrorBlock)completion {
    NSDictionary *query = @{@"action": @"updateStoryPrivacy",
                            @"privacySetting": SKStringFromStoryPrivacy(privacy),
                            @"storyFriendsToBlock": friends.JSONString,
                            @"username": self.username};
    [self postTo:kepSettings query:query callback:^(NSDictionary *json, NSError *error) {
        [self handleCallback:json error:error callback:completion];
    }];
}

- (void)updateEmail:(NSString *)address completion:(ErrorBlock)completion {
    NSParameterAssert(address);
    NSDictionary *query = @{@"action": @"updateEmail",
                            @"email": address,
                            @"username": self.username};
    [self postTo:kepSettings query:query callback:^(NSDictionary *json, NSError *error) {
        [self handleCallback:json error:error callback:completion];
    }];
}

- (void)updateSearchableByNumber:(BOOL)searchable completion:(ErrorBlock)completion {
    NSDictionary *query = @{@"action": @"updateSearchableByPhoneNumber",
                            @"searchable": @(searchable),
                            @"username": self.username};
    [self postTo:kepSettings query:query callback:^(NSDictionary *json, NSError *error) {
        [self handleCallback:json error:error callback:completion];
    }];
}

- (void)updateNotificationSoundSetting:(BOOL)enableSound completion:(ErrorBlock)completion {
    NSDictionary *query = @{@"action": @"updateNotificationSoundSetting",
                            @"notificationSoundSetting": enableSound ? @"ON" : @"OFF",
                            @"username": self.username};
    [self postTo:kepSettings query:query callback:^(NSDictionary *json, NSError *error) {
        [self handleCallback:json error:error callback:completion];
    }];
}

- (void)updateDisplayName:(NSString *)displayName completion:(ErrorBlock)completion {
    [self updateDisplayNameForUser:self.username newName:displayName completion:completion];
}


- (void)updateFeatureSettings:(NSDictionary *)settings completion:(ErrorBlock)completion {
    NSParameterAssert(settings.allKeys.count < 5);
    if (!settings.allKeys.count) {
        if (completion)
            completion(nil);
        return;
    }
    
    NSDictionary *features = @{SKFeatureFrontFacingFlash: settings[SKFeatureFrontFacingFlash] ?: @(self.currentSession.enableFrontFacingFlash),
                               SKFeatureReplaySnaps:      settings[SKFeatureReplaySnaps] ?: @(self.currentSession.enableReplaySnaps),
                               SKFeatureSmartFilters:     settings[SKFeatureSmartFilters] ?: @(self.currentSession.enableSmartFilters),
                               SKFeatureVisualFilters:    settings[SKFeatureVisualFilters] ?: @(self.currentSession.enableVisualFilters)};
    
    NSDictionary *query = @{@"settings": features.JSONString,
                            @"username": self.username};
    [self postTo:kepFeatures query:query callback:^(id object, NSError *error) {
        completion(error);
    }];
}

- (void)downloadSnaptag:(ResponseBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *query = @{@"image": self.currentSession.QRPath,
                            @"username": self.username};
    [SKRequest postTo:kepSnaptag query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
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

- (void)uploadSnaptagAvatar:(NSArray *)datas completion:(ErrorBlock)completion {
    // multipart/form-data; takes a single "data" parameter in addition to the usual "username" param
}

- (void)downloadSnaptagAvatarForUser:(NSString *)username completion:(ResponseBlock)completion {
    NSParameterAssert(completion);
    
    NSDictionary *query = @{@"username": self.username,
                            @"size": @"MEDIUM",
                            @"username_image": username};
    [SKRequest postTo:kepDownloadSnaptagAvatar query:query gauth:self.googleAuthToken token:self.authToken callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                    if (data.length)
                        [[SKBlob blobWithData:data] decompress:^(SKBlob *blob, NSError *error) {
                            completion(blob, error);
                        }];
                    else
                        completion(nil, [SKRequest errorWithMessage:@"Error retrieving snaptag" code:1]);
                }
            } else {
                completion(nil, error);
            }
        });
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
    [self postTo:kepUpdateUser query:query callback:^(NSDictionary *json, NSError *error) {
        completion(error);
    }];
}

@end
