//
//  SKClient+Account.h
//  SnapchatKit
//
//  Created by Tanner on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKClient.h"

@interface SKClient (Account)

/** @param number From 3-7 */
- (void)updateBestFriendsCount:(NSUInteger)number completion:(ErrorBlock)completion;
- (void)updateSnapPrivacy:(SKSnapPrivacy)privacy completion:(ErrorBlock)completion; // logged boolValue
/** @param friends  A list of strings of usernames to hide your stories from. Used only when @c privacy is @c SKStoryPrivacyCustom. You may pass @c nil for this parameter. */
- (void)updateStoryPrivacy:(SKStoryPrivacy)privacy hideFrom:(NSArray *)friends completion:(ErrorBlock)completion;
- (void)updateEmail:(NSString *)address completion:(ErrorBlock)completion;
- (void)updateSearchableByNumber:(BOOL)searchable completion:(ErrorBlock)completion;
- (void)updateNotificationSoundSetting:(BOOL)enableSound completion:(ErrorBlock)completion;
- (void)updateDisplayName:(NSString *)displayName completion:(ErrorBlock)completion;

- (void)updateFeatureSettings:(NSDictionary *)settings completion:(ErrorBlock)completion;

/** Completion takes an SKBlob object. */
- (void)downloadSnaptag:(ResponseBlock)completion;


@end
