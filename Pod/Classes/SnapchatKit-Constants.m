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
    
    [NSException raise:NSInternalInconsistencyException format:@"Value %lu cannot be converted to an SKAddSource string", addSource];
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
    
    [NSException raise:NSInternalInconsistencyException format:@"Value %lu cannot be converted to an SKMediaKind string", mediaKind];
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
    
    [NSException raise:NSInternalInconsistencyException format:@"Value %lu cannot be converted to an SKStoryPrivacy string", storyPrivacy];
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
    .userAgent         = @"SafetyNet/7329000 (klte KOT49H); gzip",
    .certificateDigest = @"Lxyq/KHtMNC044hj7vq+oOgVcR+kz3m4IlGaglnZWlg=",
    .GMSVersion        = 7329038,
    .digest9_8         = @"vXCcGhQ7RfL1LUiE3F6vcNORNo7IFSOvuDBunK87mEI=",
    .digest9_9         = @"Yk9Wqmx7TrTatldWI+5PWbQjGA8Gi8ZoO8X9OUAw1hg=",
    .digest9_10        = @"JJShKOLH4YYjWZlJQ71A2dPTcmxbaMboyfo0nsKYayE=",
    .digest9_11        = @"nNsTUhHYJ943NG6vAPNl+tRr1vktNb9HpvRxZuu/rrE=",
    .digest9_12_0_1    = @"W4snbl56it9XbT2lsL4gyHwMsElnmOPBDp+iIYqbGcI=",
    .digest9_12_1      = @"fGZExseKdFH1bltkKloaAGfGx0vnKDDymKiJAiLo3dU=",
    .digest9_12_2      = @"LMQNajaQ4SO7vNaQS1FRokxCtQXeIHwKZiJYhMczDGk=",
    .digest9_13        = @"BWDe2a5b3I26Yw6z4Prvh2aEMRcf2B1FMs8136QIeCM=",
    .digest9_14        = @"k6IftsTIpJeVhZDoHZv9zxDhE7HuN50PpO3O/zIXxsU=",
    .droidGuard        = @"CgbMYHoVNWLYAQE4YRoMCMKa2IIDEKC349kCqgERCLikhu8CEKL-jf34_____wHoAfLYvrb7_____wHoAbjLt877_____wE4azhLEokMuKToh_JDOAH8CvNUrmmbUkT045BmT6P_KNQSwOPtKxfJzK43U0I8A3x9lhvIbj5rbW3EREoNXLsI4okM7eonVUPt_PNYSK-b3U-T_bCfQkhKZ6hQ2ByXyi81LMp9IbzCho9KzRi_3zn9ffewSW2UjaGj71_gm4iapZXcQCigaWJ28VW10g8aeVcXVnXMg7UfDfx7NXghb0ZtlNXu8QxSCTWzUrW5nQH_TcYVKKhO4uFkX_sPr9MVwchg5oUSfvAZ2X2ZnsrkszrUr_NtlLS3w56DnPJvcOnN7X0N70p5Hj8Uqlx-a39c6BO4zfd_TAsqiV02zLoVctaht332OHA8Ejh1tIs89d0xKryMBq3OUSKKfLuMcfohU9gLuYF5_yfh3LGt2A4KSlUF1_DKcgxhiBV-QlNJWOL45fXjPl1_h7KcxfegJy19tpZ8cZ_KAWd4W00NJb5AmSGnzIB0iAkh0iC6fwpxngWS9ew_1gQC68wHrxZ8oBsLjZyzWk1eV69Xt3FSsTRzhpaIgnveaEtRZt6KsZUy2sCgzU1BvBF-Cm9kW1taPLvhURVxljUABxyKSsEmCFkyJbKDqz6bnTmAEXoJVJ3OW0OW9bpLX7IsKSlnIKOAnET0aH0e7CLkpj2nke8h8nv5PoW-s60Cc_5SirP4hTZRJDvXJecYljQcTTX6MOKx-gRiLdvc0NWzow8yrGTuCqQ0rYBEUELh8U7dGYQk6WX92aJEWa6uZb3AN9WFGg0GxiY1Bpq9kO58mHSBqeJXCrQ4mq2GJJxhxUE13zzbqsWyPi66MbTH1-YRTrjVPj5nkZqomuCtWIyWnC573IyG37lt8eYLXLNTbwuVDmUfaXytgntNExITdf9iiN2zFEYAlKSEROMc3FEKwApy9zzeTC9ItHsXGm63vv9s_2zaKEk4kUP3ozNfIMYeImk2piUs5OhEzpdAx_xyHbQICac2IA5arJ0_kqZ42tcuIjnzw8IJuU4xTDfEK12Ju7HaK8KA2i8v5Wtv28EQdqUUXByM39t_u16yI2y_Me545HGO18r-GCH3XJPe1GqwMq_J8vJSx3ecZhEXWBOZsyW5OvZ4YjHULRBDphZpyOmVsW7pLUprr42cU1BtitQy0aJm-qzd1ud4FspjRf-bsuRvWruqdqPTG80NbB-WUPCDNTSZ49bwQ9_CW0VQbqzDRupyG-xl16DwCWvqeWVd-v2DYTKCESsKfJhUHmYyK_GbTgsEioZIKmgN6UERMYLxKRRibkT8r0vWpsqx53xB_MenVzfOmpsOCJt5ITalsMVINUnuYekYw1YG9b6HRLtR4dSZj36j6gMDwGpOEPtHeEt6Fjym0SjMNA6kL2qp8rqxSiKrc37RE7Y6f6d2RlarGZG5woPl59F4onBR3Z1SR5mc9Srzrsezn6petEl19w0GtPocw5mrbYphgmjqGKNKqgLCKQ5yhfA1FQMkaZQQSJRd_zg5DuKUr7Bi_fc0ag-iJ1YqCrSiR-AmZV2DUGcNuYe9BOKt70GpfYfyc2DIcSA6oNNnRyi5uqjA7FUvggsWh80s-1yHSl4klFmQN0X10X-FszbmP2PYOlipbG6lNe2qCdlT49XgO17625Spfu7ehpeP-wRjWxgG5A-l7HabM3BrJRvYiW4YXWmloH2C8qOiqnHtC_mDjWAChSK9unVfMLQOeHiBInGR3s44wZvgtVzn_uSHuIacbqCr8VW-efmRVJ5m3iNado9smCCn74xnkMFR4_nRTCz-uwTsQp6Vvk7A6B-avGIkSBWK26nn7p0wB-btIYVZhbHlvs7eRL4PF5sc7gDgS6fpTVOVTCUEUYDfOeyu2TD-JUv0tnNxyH8zdeMHYjtQKgHDNMoWHlA1ly_1BqbU2urn3N07I4BuoBWhSfzcsRmOXtBtylCrVRhC9MEOR-I8QGgFByZfixG4XwGQnbCx-LyAtn6ngcii79W0pA8AoG_-a0s-3aIebEpcz2_qPXqxZ1qk4ByA10VjIBTC73vY1_ChkHg6bvmOsgYcrOFmD9nrbBCgapBGOx_yWsPLLwAD-cGj"
};

#pragma mark Misc
SK_NAMESPACE_IMP(SKConsts) {
    .baseURL           = @"https://feelinsonice-hrd.appspot.com",
    .userAgent         = @"Snapchat/9.14.0.0 (SM-N9005; Android 5.0.2; gzip)", //Snapchat/9.10.0.0 (HTC One; Android 4.4.2#302626.7#19; gzip)";
    .eventsURL         = @"https://sc-analytics.appspot.com/post_events",
    .analyticsURL      = @"https://sc-analytics.appspot.com/analytics/bz",
    .secret            = @"iEk21fuwZApXlz93750dmW22pw389dPwOk",
    .staticToken       = @"m198sOkJEn37DjqZ32lpRu76xmw288xSQ9",
    .blobEncryptionKey = @"M02cnQ51Ji97vwT4",
    .hashPattern       = @"0001110111101110001111010101111011010001001110011000110001000110",
    .boundary          = @"Boundary+0xAbCdEfGbOuNdArY",
    .deviceToken1i     = @"dtoken1i",
    .deviceToken1v     = @"dtoken1v",
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
    .values = {
        .language    = @"en",
        .locale      = @"en_US",
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

SK_NAMESPACE_IMP(SKEPMisc) {
    .ping          = @"/loq/ping",
    .locationData  = @"/loq/loc_data",
    .serverList    = @"/loq/gae_server_list",
    .doublePost    = @"/loq/double_post",
    .reauth        = @"/bq/reauth",
    .suggestFriend = @"/bq/suggest_friend"
};

SK_NAMESPACE_IMP(SKEPUpdate) {
    .all             = @"/loq/all_updates",
    .snaps           = @"/bq/update_snaps",
    .stories         = @"/bq/update_stories",
    .user            = @"/loq/update_user", // just /update_stories?
    .featureSettings = @"/bq/update_feature_settings"
};

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

SK_NAMESPACE_IMP(SKEPDevice) {
    .IPRouting      = @"/bq/ip_routing",
    .IPRoutingError = @"/bq/ip_routing_error",
    .identifier     = @"/loq/device_id",
    .device         = @"/ph/device"
};

SK_NAMESPACE_IMP(SKEPDiscover) {
    .channels = @"/discover/channel_list?region=",
    .icons    = @"/discover/icons?icon=",
    .snaps    = @"/discover/dsnaps?edition_id=",  // &snap_id= &hash= &publisher= &currentSession.resourceParamName=currentSession.resourceParamValue
    .intros   = @"/discover/intro_videos?publisher="  // &intro_video= &currentSession.resourceParamName=currentSession.resourceParamValue
};

SK_NAMESPACE_IMP(SKEPFriends) {
    .find       = @"/ph/find_friends",
    .findNearby = @"/bq/find_nearby_friends",
    .bests      = @"/bq/bests",
    .friend     = @"/bq/friend",
    .hide       = @"/loq/friend_hide",
    .search     = @"/loq/friend_search",
    .exists     = @"/bq/user_exists"
};

SK_NAMESPACE_IMP(SKEPSnaps) {
    .loadBlob = @"/bq/blob", // /ph/blob ?
    .upload   = @"/ph/upload",
    .send     = @"/loq/retry",
    .retry    = @"/loq/send"
};

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

SK_NAMESPACE_IMP(SKEPAndroid) {
    .findNearbyFriends = @"/bq/and/find_nearby_friends",
    .changeEmail       = @"/loq/and/change_email",
    .changePass        = @"/loq/and/change_password",
    .getPassStrength   = @"/loq/and/get_password_strength",
    .registerExp       = @"/loq/and/register_exp",
};



NSString * const kepSharedDescription     = @"/shared/description";
