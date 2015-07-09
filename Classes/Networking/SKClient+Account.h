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

/** Updates the number of best friends to display.
 @param number A number from 3 to 7. Defaults to 3 and will max out at 7.
 @param completion Passed an error, if any. */
- (void)updateBestFriendsCount:(NSUInteger)number completion:(ErrorBlock)completion;
/** Updates who can send you snaps.
 @param privacy \c SKSnapPrivacyFriends or \c SKSnapPrivacyEveryone. Defaults to \c SKSnapPrivacyEveryone.
 @param completion Passed an error, if any. */
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
/** @param datas An array of 5 image @c NSData objects. */
- (void)uploadSnaptagAvatar:(NSArray *)datas completion:(ErrorBlock)completion;
/** Completion *should* take an array of 5 @c SKBlob objects, but as of now takes one possibly encrypted @c SKBlob object. */
- (void)downloadSnaptagAvatarForUser:(NSString *)username completion:(ResponseBlock)completion;
- (void)updateTOSAgreementStatus:(BOOL)snapcash snapcashV2:(BOOL)snapcashV2 square:(BOOL)square completion:(ErrorBlock)completion;


@end
