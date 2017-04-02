//
//  SnapchatKit-Constants.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SnapchatKit-Constants.h"

#pragma mark Extern functions

void SKLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSMutableString * message = [[NSMutableString alloc] initWithFormat:format arguments:args];
    NSLogv(message, args);
    va_end(args);
}

SKAddSource SKAddSourceFromString(NSString *addSourceString) {
    if (![addSourceString isEqualToString:@"UNRECOGNIZED_VALUE"]) {
        NSLog(@"Value '%@' cannot be converted to an SKAddSource", addSourceString);
    }
    if ([addSourceString isEqualToString:@"ADDED_BY_PHONE"])
        return SKAddSourcePhonebook;
    if ([addSourceString isEqualToString:@"ADDED_BY_USERNAME"])
        return SKAddSourceUsername;
    if ([addSourceString isEqualToString:@"ADDED_BY_ADDED_ME_BACK"])
        return SKAddSourceAddedBack;
    if ([addSourceString isEqualToString:@"ADDED_BY_QR_CODE"])
        return SKAddSourceQRCode;
    if ([addSourceString isEqualToString:@"ADDED_BY_NEARBY"])
        return SKAddSourceNearby;
    
    return SKAddSourceUnrecognizedValue;
}

NSString * SKStringFromAddSource(SKAddSource addSource) {
    switch (addSource) {
        case SKAddSourceUnrecognizedValue:
            return @"UNRECOGNIZED_VALUE";
        case SKAddSourcePhonebook:
            return @"ADDED_BY_PHONE";
        case SKAddSourceUsername:
            return @"ADDED_BY_USERNAME";
        case SKAddSourceAddedBack:
            return @"ADDED_BY_ADDED_ME_BACK";
        case SKAddSourceQRCode:
            return @"ADDED_BY_QR_CODE";
        case SKAddSourceNearby:
            return @"ADDED_BY_NEARBY";
    }
    
    return nil;
}

NSString * SKStringFromMediaKind(SKMediaKind mediaKind) {
    switch (mediaKind) {
        case SKMediaKindImage:
            return @"SKMediaKindImage";
        case SKMediaKindVideo:
            return @"SKMediaKindVideo";
        case SKMediaKindSilentVideo:
            return @"SKMediaKindSilentVideo";
        case SKMediaKindFriendRequest:
            return @"SKMediaKindFriendRequest";
        case SKMediaKindStrangerImage:
            return @"SKMediaKindStrangerImage";
        case SKMediaKindStrangerVideo:
            return @"SKMediaKindStrangerVideo";
        case SKMediaKindStrangerSilentVideo:
            return @"SKMediaKindStrangerSilentVideo";
    }
    
    //    [NSException raise:NSInternalInconsistencyException format:@"Value %lu cannot be converted to an SKMediaKind string", (long)mediaKind];
    SKLog(@"Value %lu cannot be converted to an SKMediaKind string", (long)mediaKind);
    return nil;
}

NSString * SKStringFromStoryPrivacy(SKStoryPrivacy storyPrivacy) {
    switch (storyPrivacy) {
        case SKStoryPrivacyEveryone:
            return @"EVERYONE";
        case SKStoryPrivacyFriends:
            return @"FRIENDS";
        case SKStoryPrivacyCustom:
            return @"CUSTOM";
    }
    
    //    [NSException raise:NSInternalInconsistencyException format:@"Value %lu cannot be converted to an SKStoryPrivacy string", (unsigned long)storyPrivacy];
    SKLog(@"Value %lu cannot be converted to an SKStoryPrivacy string", (unsigned long)storyPrivacy);
    return nil;
}

NSString * SKStringFromAvatarSize(SKAvatarSize avatarSize) {
    switch (avatarSize) {
        case SKAvatarSizeThumbnail:
            return @"THUMBNAIL";
        case SKAvatarSizeMedium:
            return @"MEDIUM";
        case SKAvatarSizeLarge:
            return @"BIG";
    }
    
    [NSException raise:NSInternalInconsistencyException format:@"Value %lu cannot be converted to an SKAvatarSize string", (unsigned long)avatarSize];
    return nil;
}

BOOL SKMediaKindIsImage(SKMediaKind mediaKind) {
    return mediaKind == SKMediaKindImage || mediaKind == SKMediaKindStrangerImage;
}

BOOL SKMediaKindIsVideo(SKMediaKind mediaKind) {
    return mediaKind == SKMediaKindVideo || mediaKind == SKMediaKindSilentVideo || mediaKind == SKMediaKindStrangerVideo || mediaKind == SKMediaKindStrangerSilentVideo;
}

NSString * const SKNoConversationExistsYet = @"No conversation exists between these users.";
NSString * const SKTemporaryLoginFailure = @"Oh no! Your login temporarily failed, so please try again later. If your login continues to fail, please visit https://support.snapchat.com/a/failed-login :)";




#pragma mark - General API constants -

#pragma mark Misc
SK_NAMESPACE_IMP(SKConsts) {
    .baseURL           = @"https://app.snapchat.com",
    .userAgent         = @"Snapchat/9.21.0.1 (iPhone8,1; iOS 9.0.2; gzip)",//@"Snapchat/9.16.1.0 (SM-N9005; Android 5.0.2; gzip)", //Snapchat/9.16.1.0 (HTC One; Android 4.4.2#302626.7#19; gzip)",
    .eventsURL         = @"https://sc-analytics.appspot.com/post_events",
    .analyticsURL      = @"https://sc-analytics.appspot.com/analytics/bz",
    .secret            = @"iEk21fuwZApXlz93750dmW22pw389dPwOk",
    .staticToken       = @"m198sOkJEn37DjqZ32lpRu76xmw288xSQ9",
    .blobEncryptionKey = @"M02cnQ51Ji97vwT4",
    .hashPattern       = @"0001110111101110001111010101111011010001001110011000110001000110",
    .boundary          = @"Boundary+0xAbCdEfGbOuNdArY",
    .deviceToken1i     = @"dtoken1i",
    .deviceToken1v     = @"dtoken1v",
    .snapchatVersion   = @"9.21.0.1"
};

#pragma mark Header fields / values
SK_NAMESPACE_IMP(SKHeaders) {
    .timestamp       = @"X-Timestamp",
    .clientAuth      = @"X-Snapchat-Client-Auth",
    .clientToken     = @"X-Snapchat-Client-Token",
    .clientAuthToken = @"X-Snapchat-Client-Auth-Token",
    .casperAPIKey    = @"X-Casper-API-Key",
    .casperSignature = @"X-Casper-Signature",
    .values = {
        .language      = @"en",
        .locale        = @"en_US",
        .droidGuardUA  = @"DroidGuard/7329000 (A116 _Quad KOT49H); gzip",
        .protobuf      = @"application/x-protobuf"
    }
};

#pragma mark Feature settings
SK_NAMESPACE_IMP(SKFeatureSettings) {
    .smartFilters        = @"smart_filters",
    .visualFilters       = @"visual_filters",
    .travelMode          = @"travel_mode",
    .barcodeEnabled      = @"barcode_enabled",
    .payReplaySnaps      = @"pay_replay_snaps",
    .lensStoreEnabled    = @"lens_store_available",
    .prefetchLensStore   = @"is_prefetch_for_store_lenses_enabled",
    .QRCodeEnabled       = @"qrcode_enabled",
    .scrambleBestFriends = @"scramble_best_friends"
};


#pragma mark - Endpoints -

#pragma mark SKEPMisc
SK_NAMESPACE_IMP(SKEPMisc) {
    .ping          = @"/loq/ping",
    .locationData  = @"/loq/loc_data",
    .serverList    = @"/loq/gae_server_list",
    .doublePost    = @"/loq/double_post",
    .reauth        = @"/bq/reauth",
    .suggestFriend = @"/bq/suggest_friend"
};

#pragma mark SKEPUpdate
SK_NAMESPACE_IMP(SKEPUpdate) {
    .all             = @"/loq/all_updates",
    .snaps           = @"/bq/update_snaps",
    .stories         = @"/bq/update_stories", // just /update_stories?
    .user            = @"/loq/update_user",
    .trophies        = @"/bq/ios/trophies",
    .featureSettings = @"/bq/update_feature_settings"
};

#pragma mark SKEPAccount
SK_NAMESPACE_IMP(SKEPAccount) {
    .login             = @"/loq/login",
    .logout            = @"/ph/logout",
    .twoFAPhoneVerify  = @"/loq/two_fa_phone_verify",
    .twoFARecoveryCode = @"/loq/two_fa_recovery_code",
    .setBestsCount     = @"/bq/set_num_best_friends",
    .settings          = @"/ph/settings",
    .snaptag           = @"/bq/snaptag_download",
    .registration = {
        .start           = @"/loq/register",
        .username        = @"/loq/register_username",
        .getCaptcha      = @"/bq/get_captcha",
        .solveCaptcha    = @"/bq/solve_captcha",
        .verifyPhone     = @"/bq/phone_verify",
        .suggestUsername = @"/bq/suggest_username",
    },
    .avatar = {
        .set       = @"/bq/upload_profile_data",
        .get       = @"/bq/download_profile_data",
        .remove    = @"/bq/delete_profile_data",
        .getFriend = @"/bq/download_friends_profile_data",
    }
};

#pragma mark SKEPChat
SK_NAMESPACE_IMP(SKEPChat) {
    .sendMessage   = @"/loq/conversation_post_messages",
    .conversation  = @"/loq/conversation",
    .conversations = @"/loq/conversations",
    .authToken     = @"/loq/conversation_auth_token",
    .clear         = @"/ph/clear",
    .clearFeed     = @"/loq/clear_feed",
    .clearConvo    = @"/loq/clear_conversation",
    .typing        = @"/bq/chat_typing",
    .media         = @"/bq/chat_media",
    .uploadMedia   = @"/bq/upload_chat_media",
    .shareMedia    = @"/loq/conversation_share_media"
};

#pragma mark SKEPDevice
SK_NAMESPACE_IMP(SKEPDevice) {
    .IPRouting      = @"/bq/ip_routing",
    .IPRoutingError = @"/bq/ip_routing_error",
    .identifier     = @"/loq/device_id",
    .device         = @"/ph/device"
};

#pragma mark SKEPDiscover
SK_NAMESPACE_IMP(SKEPDiscover) {
    .channels = @"/discover/channel_list?region=",
    .icons    = @"/discover/icons?icon=",
    .snaps    = @"/discover/dsnaps?edition_id=",  // &snap_id= &hash= &publisher= &currentSession.resourceParamName=currentSession.resourceParamValue
    .intros   = @"/discover/intro_videos?publisher="  // &intro_video= &currentSession.resourceParamName=currentSession.resourceParamValue
};

#pragma mark SKEPFriends
SK_NAMESPACE_IMP(SKEPFriends) {
    .find       = @"/ph/find_friends",
    .findNearby = @"/bq/find_nearby_friends",
    .bests      = @"/bq/bests",
    .friend     = @"/bq/friend",
    .hide       = @"/loq/friend_hide",
    .search     = @"/loq/friend_search",
    .exists     = @"/bq/user_exists"
};

#pragma mark SKEPSnaps
SK_NAMESPACE_IMP(SKEPSnaps) {
    .loadBlob = @"/bq/blob",
    .upload   = @"/bq/upload",
    .send     = @"/loq/retry",
    .retry    = @"/loq/send"
};

#pragma mark SKEPStories
SK_NAMESPACE_IMP(SKEPStories) {
    .stories   = @"/bq/stories",
    .upload    = @"/bq/upload",
    .blob      = @"/bq/story_blob?story_id=",
    .thumb     = @"/bq/story_thumbnail?story_id=",
    .authBlob  = @"/bq/auth_story_blob",
    .authThumb = @"/bq/auth_story_thumbnail",
    .remove    = @"/bq/delete_story",
    .post      = @"/bq/post_story",
    .retryPost = @"/bq/retry_post_story",
    .sharedDescription = @"/shared/description"
};

#pragma mark SKEPCash
SK_NAMESPACE_IMP(SKEPCash) {
    .checkRecipientEligibility = @"/cash/check_recipient_eligible",
    /** Takes only \c username, returns: @code
     {
     "access_token": {
     "access_token": "GVkM5JUEpgs_Ekh_weoxUA",
     "expires_at": "2015-08-02T07:45:41Z",
     "token_type": "bearer"
     },
     "status": "OK"
     }
     @endcode
     */
    .generateAccessToken       = @"/cash/generate_access_token",
    .generateSignature         = @"/cash/generate_signature_for_phone",
    .markViewed                = @"/cash/mark_as_viewed",
    .resetAccount              = @"/cash/reset_account",
    .transaction               = @"/cash/transaction",
    .updateTransaction         = @"/cash/update_transaction",
    .validateTransaction       = @"/cash/validate_transaction",
};

#pragma mark SKEPAndroid
SK_NAMESPACE_IMP(SKEPAndroid) {
    .findNearbyFriends = @"/bq/and/find_nearby_friends",
    .changeEmail       = @"/loq/and/change_email",
    .changePass        = @"/loq/and/change_password",
    .getPassStrength   = @"/loq/and/get_password_strength",
    .registerExp       = @"/loq/and/register_exp",
};
