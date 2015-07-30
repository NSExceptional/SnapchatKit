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
 @param privacy \c SKSnapPrivacyFriends or \c SKSnapPrivacyEveryone. Defaults to \c SKSnapPrivacyFriends.
 @param completion Takes an error, if any. */
- (void)updateSnapPrivacy:(SKSnapPrivacy)privacy completion:(ErrorBlock)completion; // logged boolValue
/** Updates who can see your stories. \e friends is only necessary when using \c SKStoryPrivacyCustom.
 @warning Passing invalid values to \e privacy raises an exception.
 @param privacy \c SKStoryPrivacyEveryone, \c SKStoryPrivacyFriends, \c SKStoryPrivacyCustom.
 @param friends  A list of strings of usernames to hide your stories from. Used only when \c privacy is \c SKStoryPrivacyCustom. You may pass \c nil for this parameter.
 @param completion Takes an error, if any. */
- (void)updateStoryPrivacy:(SKStoryPrivacy)privacy hideFrom:(NSArray *)friends completion:(ErrorBlock)completion;

/** Updates your account's email address.
 @param address Your new email address.
 @param completion Takes an error, if any. */
- (void)updateEmail:(NSString *)address completion:(ErrorBlock)completion;
/** Updates whether your account can be found with your phone number.
 @param searchable The new value for this preference.
 @param completion Takes an error, if any. */
- (void)updateSearchableByNumber:(BOOL)searchable completion:(ErrorBlock)completion;

/** Updates your "notification sounds" preference.
 @param enableSound The new value for this preference.
 @param completion Takes an error, if any. */
- (void)updateNotificationSoundSetting:(BOOL)enableSound completion:(ErrorBlock)completion;
/** Updates your display name.
 @discussion Your "display name" is what your contact name defaults to when someone new adds you, not your username.
 @param displayName Your new display name.
 @param completion Takes an error, if any. */
- (void)updateDisplayName:(NSString *)displayName completion:(ErrorBlock)completion;
/** Updates your account's feature settings.
 @discussion See the \c SKFeature string constants in \c SnapchatKit-Constants.h for valid keys. Invalid keys will be silently ignored.
 @param settings A dictionary of string-boolean pairs. Missing keys-value pairs default to the current values. Behavior is undefined for values other than @YES and @NO.
 @warning Raises an exception if \e settings contains more than 8 key-value pairs.
 @param completion Takes an error, if any. */
- (void)updateFeatureSettings:(NSDictionary *)settings completion:(ErrorBlock)completion;

/** Downloads your account's snaptag, a personal Snapchat QR code.
 @param completion Takes an error, if any, and an SKBlob object with the snaptag data. */
- (void)downloadSnaptag:(ResponseBlock)completion;
/** Uploads a new animated avatar. Not working yet.
 @param datas An array of 5 image \c NSData objects.
 @param completion Takes an error, if any. */
- (void)uploadAvatar:(NSArray *)datas completion:(ErrorBlock)completion;
/** Downloads the animated avatar for \c user. Currently encrypted, or something.
 @param username The username tied to the avatar to download.
 @param completion Takes an error, if any, and ideally an array of 5 \c SKBlob objects or \c nil if the user does not have an avatar, but as of now takes one possibly encrypted \c SKBlob object. */
- (void)downloadAvatar:(NSString *)username completion:(ResponseBlock)completion;
/** Updates your TOS agreement status for each of the three Terms of Service's.
 @param completion Takes an error, if any. */
- (void)updateTOSAgreementStatus:(BOOL)snapcash snapcashV2:(BOOL)snapcashV2 square:(BOOL)square completion:(ErrorBlock)completion;


@end
