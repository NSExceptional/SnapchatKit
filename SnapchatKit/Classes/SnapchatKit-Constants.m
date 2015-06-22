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
    
    return nil;
}

BOOL SKMediaKindIsImage(SKMediaKind mediaKind) {
    return mediaKind == SKMediaKindImage || mediaKind == SKMediaKindStrangerImage;
}

BOOL SKMediaKindIsVideo(SKMediaKind mediaKind) {
    return mediaKind == SKMediaKindVideo || mediaKind == SKMediaKindSilentVideo || mediaKind == SKMediaKindStrangerVideo || mediaKind == SKMediaKindStrangerSilentVideo;
}

#pragma mark General API constants
NSString * const kUserAgent               = @"Snapchat/9.10.0.0 (HTC One; Android 4.4.2#302626.7#19; gzip)";
NSString * const kUserAgentForAttestation = @"SafetyNet/7329000 (klte KOT49H); gzip";
NSString * const kURL                     = @"https://feelinsonice-hrd.appspot.com";
NSString * const kEventsURL               = @"https://sc-analytics.appspot.com/post_events";
NSString * const kSecret                  = @"iEk21fuwZApXlz93750dmW22pw389dPwOk";
NSString * const kStaticToken             = @"m198sOkJEn37DjqZ32lpRu76xmw288xSQ9";
NSString * const kBlobEncryptionKey       = @"M02cnQ51Ji97vwT4";
NSString * const kHashPattern             = @"0001110111101110001111010101111011010001001110011000110001000110";
NSString * const kBoundary                = @"Boundary+0xAbCdEfGbOuNdArY";
NSString * const kAPKDigest               = @"JJShKOLH4YYjWZlJQ71A2dPTcmxbaMboyfo0nsKYayE=";
NSString * const kAPKCertificateDigest    = @"Lxyq/KHtMNC044hj7vq+oOgVcR+kz3m4IlGaglnZWlg=";
NSString * const kGMSVersion              = @"7329038";
NSString * const kDroidGuard              = @"CgbMYHoVNWLYAQE4YRoMCMKa2IIDEKC349kCqgERCLikhu8CEKL-jf34_____wHoAfLYvrb7_____wHoAbjLt877_____wE4azhLEokMuKToh_JDOAH8CvNUrmmbUkT045BmT6P_KNQSwOPtKxfJzK43U0I8A3x9lhvIbj5rbW3EREoNXLsI4okM7eonVUPt_PNYSK-b3U-T_bCfQkhKZ6hQ2ByXyi81LMp9IbzCho9KzRi_3zn9ffewSW2UjaGj71_gm4iapZXcQCigaWJ28VW10g8aeVcXVnXMg7UfDfx7NXghb0ZtlNXu8QxSCTWzUrW5nQH_TcYVKKhO4uFkX_sPr9MVwchg5oUSfvAZ2X2ZnsrkszrUr_NtlLS3w56DnPJvcOnN7X0N70p5Hj8Uqlx-a39c6BO4zfd_TAsqiV02zLoVctaht332OHA8Ejh1tIs89d0xKryMBq3OUSKKfLuMcfohU9gLuYF5_yfh3LGt2A4KSlUF1_DKcgxhiBV-QlNJWOL45fXjPl1_h7KcxfegJy19tpZ8cZ_KAWd4W00NJb5AmSGnzIB0iAkh0iC6fwpxngWS9ew_1gQC68wHrxZ8oBsLjZyzWk1eV69Xt3FSsTRzhpaIgnveaEtRZt6KsZUy2sCgzU1BvBF-Cm9kW1taPLvhURVxljUABxyKSsEmCFkyJbKDqz6bnTmAEXoJVJ3OW0OW9bpLX7IsKSlnIKOAnET0aH0e7CLkpj2nke8h8nv5PoW-s60Cc_5SirP4hTZRJDvXJecYljQcTTX6MOKx-gRiLdvc0NWzow8yrGTuCqQ0rYBEUELh8U7dGYQk6WX92aJEWa6uZb3AN9WFGg0GxiY1Bpq9kO58mHSBqeJXCrQ4mq2GJJxhxUE13zzbqsWyPi66MbTH1-YRTrjVPj5nkZqomuCtWIyWnC573IyG37lt8eYLXLNTbwuVDmUfaXytgntNExITdf9iiN2zFEYAlKSEROMc3FEKwApy9zzeTC9ItHsXGm63vv9s_2zaKEk4kUP3ozNfIMYeImk2piUs5OhEzpdAx_xyHbQICac2IA5arJ0_kqZ42tcuIjnzw8IJuU4xTDfEK12Ju7HaK8KA2i8v5Wtv28EQdqUUXByM39t_u16yI2y_Me545HGO18r-GCH3XJPe1GqwMq_J8vJSx3ecZhEXWBOZsyW5OvZ4YjHULRBDphZpyOmVsW7pLUprr42cU1BtitQy0aJm-qzd1ud4FspjRf-bsuRvWruqdqPTG80NbB-WUPCDNTSZ49bwQ9_CW0VQbqzDRupyG-xl16DwCWvqeWVd-v2DYTKCESsKfJhUHmYyK_GbTgsEioZIKmgN6UERMYLxKRRibkT8r0vWpsqx53xB_MenVzfOmpsOCJt5ITalsMVINUnuYekYw1YG9b6HRLtR4dSZj36j6gMDwGpOEPtHeEt6Fjym0SjMNA6kL2qp8rqxSiKrc37RE7Y6f6d2RlarGZG5woPl59F4onBR3Z1SR5mc9Srzrsezn6petEl19w0GtPocw5mrbYphgmjqGKNKqgLCKQ5yhfA1FQMkaZQQSJRd_zg5DuKUr7Bi_fc0ag-iJ1YqCrSiR-AmZV2DUGcNuYe9BOKt70GpfYfyc2DIcSA6oNNnRyi5uqjA7FUvggsWh80s-1yHSl4klFmQN0X10X-FszbmP2PYOlipbG6lNe2qCdlT49XgO17625Spfu7ehpeP-wRjWxgG5A-l7HabM3BrJRvYiW4YXWmloH2C8qOiqnHtC_mDjWAChSK9unVfMLQOeHiBInGR3s44wZvgtVzn_uSHuIacbqCr8VW-efmRVJ5m3iNado9smCCn74xnkMFR4_nRTCz-uwTsQp6Vvk7A6B-avGIkSBWK26nn7p0wB-btIYVZhbHlvs7eRL4PF5sc7gDgS6fpTVOVTCUEUYDfOeyu2TD-JUv0tnNxyH8zdeMHYjtQKgHDNMoWHlA1ly_1BqbU2urn3N07I4BuoBWhSfzcsRmOXtBtylCrVRhC9MEOR-I8QGgFByZfixG4XwGQnbCx-LyAtn6ngcii79W0pA8AoG_-a0s-3aIebEpcz2_qPXqxZ1qk4ByA10VjIBTC73vY1_ChkHg6bvmOsgYcrOFmD9nrbBCgapBGOx_yWsPLLwAD-cGj";

NSString * const khfClientAuthTokenHeaderField = @"X-Snapchat-Client-Auth-Token";
NSString * const khfTimestamp                  = @"X-Timestamp";
NSString * const khfContentType                = @"Content-Type";
NSString * const khfUserAgent                  = @"User-Agent";
NSString * const khfAcceptLanguage             = @"Accept-Language";
NSString * const khfAcceptLocale               = @"Accept-Locale";
NSString * const khvLanguage                   = @"en";
NSString * const khvLocale                     = @"en_US";

NSString * const kepLogin             = @"/loq/login";
NSString * const kepLogout            = @"/ph/logout";
NSString * const kepRegister          = @"/loq/register";
NSString * const kepRegisterUsername  = @"/loq/register_username";
NSString * const kepCaptchaGet        = @"/bq/get_captcha";
NSString * const kepCaptchaSolve      = @"/bq/solve_captcha";
NSString * const kepBlob              = @"/bq/blob";
NSString * const kepChatMedia         = @"/bq/chat_media";
NSString * const kepPhoneVerify       = @"/bq/phone_verify";
NSString * const kepDeviceToken       = @"/loq/device_id";
NSString * const kepAllUpdates        = @"/loq/all_updates";
NSString * const kepConvoAuth         = @"/loq/conversation_auth_token";
NSString * const kepConversations     = @"/loq/conversations";
NSString * const kepConversation      = @"/loq/conversation";
NSString * const kepConvoClear        = @"/loq/clear_conversation";
NSString * const kepConvoPostMessages = @"/loq/conversation_post_messages";
NSString * const kepFindFriends       = @"/ph/find_friends";
NSString * const kepFriendSearch      = @"/loq/friend_search";
NSString * const kepUserExists        = @"/bq/user_exists";
NSString * const kepFriends           = @"/bq/friend";
NSString * const kepFriendHide        = @"/loq/friend_hide";
NSString * const kepUpdateSnaps       = @"/bq/update_snaps";
NSString * const kepSharedDescription = @"/shared/description";
NSString * const kepUpdateStories     = @"/bq/update_stories";
NSString * const kepUpdateUser        = @"/loq/update_user";
NSString * const kepUpload            = @"/bq/upload";
NSString * const kepRetrySend         = @"/loq/retry";
NSString * const kepSend              = @"/loq/send";
NSString * const kepTyping            = @"/bq/chat_typing";
NSString * const kepPostStory         = @"/bq/retry_post_story";
NSString * const kepDeleteStory       = @"/bq/delete_story";
NSString * const kepMarkStoryViewed   = @"/update_stories";
NSString * const kepBestFriends       = @"/bq/bests";
NSString * const kepSetBestCount      = @"/bq/set_num_best_friends";
NSString * const kepClearFeed         = @"/ph/clear";
NSString * const kepSettings          = @"/bq/settings";
NSString * const kepFeatures          = @"/bq/update_feature_settings";
NSString * const kepSnaptag           = @"/bq/snaptag_download";
NSString * const kepCashEligible      = @"/cash/check_recipient_eligible";
NSString * const kepCashGenerateToken = @"/cash/generate_access_token"; // takes only username
NSString * const kepLocationData      = @"/loq/loc_data";

NSString * const kepGetStoryBlob      = @"/bq/story_blob?story_id=";
NSString * const kepGetStoryThumb     = @"/bq/story_thumbnail?story_id=";

NSString * const SKFeatureFrontFacingFlash = @"front_facing_flash";
NSString * const SKFeatureReplaySnaps      = @"replay_snaps";
NSString * const SKFeatureSmartFilters     = @"smart_filters";
NSString * const SKFeatureVisualFilters    = @"visual_filters";
