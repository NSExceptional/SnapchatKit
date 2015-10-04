//
//  SnapchatKit-Constants.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
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
    if ([addSourceString isEqualToString:@"ADDED_BY_PHONE"])
        return SKAddSourcePhonebook;
    if ([addSourceString isEqualToString:@"ADDED_BY_USERNAME"])
        return SKAddSourceUsername;
    if ([addSourceString isEqualToString:@"ADDED_BY_ADDED_ME_BACK"])
        return SKAddSourceAddedBack;
    
    return 0;
}

NSString * SKStringFromAddSource(SKAddSource addSource) {
    switch (addSource) {
        case SKAddSourcePhonebook:
            return @"ADDED_BY_PHONE";
        case SKAddSourceUsername:
            return @"ADDED_BY_USERNAME";
        case SKAddSourceAddedBack:
            return @"ADDED_BY_ADDED_ME_BACK";
    }
    
    [NSException raise:NSInternalInconsistencyException format:@"Value %lu cannot be converted to an SKAddSource string", (long)addSource];
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
    
    [NSException raise:NSInternalInconsistencyException format:@"Value %lu cannot be converted to an SKMediaKind string", (long)mediaKind];
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
    
    [NSException raise:NSInternalInconsistencyException format:@"Value %lu cannot be converted to an SKStoryPrivacy string", (unsigned long)storyPrivacy];
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

#pragma mark Attestation
SK_NAMESPACE_IMP(SKAttestation) {
    .userAgent           = @"SafetyNet/7899000 (WIKO JZO54K); gzip",
    .certificateDigest   = @"Lxyq/KHtMNC044hj7vq+oOgVcR+kz3m4IlGaglnZWlg=",
    .GMSVersion          = 7329038,
    .protobufBytecodeURL = @"https://www.googleapis.com/androidantiabuse/v1/x/create?alt=PROTO&key=AIzaSyBofcZsgLSS7BOnBjZPEkk4rYwzOIz-lTI",
    .protobufPOSTURL     = @"https://api.casper.io/snapchat/attestation/attest",
    .attestationURL      = @"https://www.googleapis.com/androidcheck/v1/attestations/attest?alt=JSON&key=AIzaSyDqVnJBjE5ymo--oBJt3On7HQx9xNm1RHA",
    .digest9_8           = @"vXCcGhQ7RfL1LUiE3F6vcNORNo7IFSOvuDBunK87mEI=",
    .digest9_9           = @"Yk9Wqmx7TrTatldWI+5PWbQjGA8Gi8ZoO8X9OUAw1hg=",
    .digest9_10          = @"JJShKOLH4YYjWZlJQ71A2dPTcmxbaMboyfo0nsKYayE=",
    .digest9_11          = @"nNsTUhHYJ943NG6vAPNl+tRr1vktNb9HpvRxZuu/rrE=",
    .digest9_12_0_1      = @"W4snbl56it9XbT2lsL4gyHwMsElnmOPBDp+iIYqbGcI=",
    .digest9_12_1        = @"fGZExseKdFH1bltkKloaAGfGx0vnKDDymKiJAiLo3dU=",
    .digest9_12_2        = @"LMQNajaQ4SO7vNaQS1FRokxCtQXeIHwKZiJYhMczDGk=",
    .digest9_13          = @"BWDe2a5b3I26Yw6z4Prvh2aEMRcf2B1FMs8136QIeCM=",
    .digest9_14          = @"k6IftsTIpJeVhZDoHZv9zxDhE7HuN50PpO3O/zIXxsU=",
    .digest9_14_2        = @"5O40Rllov9V8PpwD5zPmmp+GQi7UMIWz2A0LWZA7UX0="
};

#pragma mark Misc
SK_NAMESPACE_IMP(SKConsts) {
    .baseURL           = @"https://feelinsonice-hrd.appspot.com",
    .userAgent         = @"Snapchat/9.16.1.0 (SM-N9005; Android 5.0.2; gzip)", //Snapchat/9.16.1.0 (HTC One; Android 4.4.2#302626.7#19; gzip)";
    .eventsURL         = @"https://sc-analytics.appspot.com/post_events",
    .analyticsURL      = @"https://sc-analytics.appspot.com/analytics/bz",
    .secret            = @"iEk21fuwZApXlz93750dmW22pw389dPwOk",
    .staticToken       = @"m198sOkJEn37DjqZ32lpRu76xmw288xSQ9",
    .blobEncryptionKey = @"M02cnQ51Ji97vwT4",
    .hashPattern       = @"0001110111101110001111010101111011010001001110011000110001000110",
    .boundary          = @"Boundary+0xAbCdEfGbOuNdArY",
    .deviceToken1i     = @"dtoken1i",
    .deviceToken1v     = @"dtoken1v",
    .snapchatVersion   = @"9.16.1.0"
};

#pragma mark Header fields / values
SK_NAMESPACE_IMP(SKHeaders) {
    .timestamp       = @"X-Timestamp",
    .userAgent       = @"User-Agent",
    .contentType     = @"Content-Type",
    .acceptLanguage  = @"Accept-Language",
    .acceptLocale    = @"Accept-Locale",
    .clientAuth      = @"X-Snapchat-Client-Auth",
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
    .frontFacingFlash = @"front_facing_flash",
    .replaySnaps      = @"replay_snaps",
    .smartFilters     = @"smart_filters",
    .visualFilters    = @"visual_filters",
    .powerSaveMode    = @"power_save_mode",
    .specialText      = @"special_text",
    .swipeCashMode    = @"swipe_cash_mode",
    .travelMode       = @"travel_mode"
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
    .stories         = @"/bq/update_stories",
    .user            = @"/loq/update_user", // just /update_stories?
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
        .get       = @"/bq/delete_profile_data",
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
    .loadBlob = @"/bq/blob", // /ph/blob ?
    .upload   = @"/ph/upload",
    .send     = @"/loq/retry",
    .retry    = @"/loq/send"
};

#pragma mark SKEPStories
SK_NAMESPACE_IMP(SKEPStories) {
    .stories   = @"/bq/stories",
    .upload    = @"/ph/upload",
    .blob      = @"/bq/story_blob?story_id=",
    .thumb     = @"/bq/story_thumbnail?story_id=",
    .authBlob  = @"/bq/auth_story_blob?story_id=",
    .authThumb = @"/bq/auth_story_thumbnail?story_id=",
    .remove    = @"/bq/delete_story",
    .post      = @"/bq/post_story",
    .retryPost = @"/bq/retry_post_story",
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



NSString * const kepSharedDescription     = @"/shared/description";
