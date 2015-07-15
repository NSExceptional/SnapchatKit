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

#pragma mark General API constants
NSString * const kUserAgent               = @"Snapchat/9.10.0.0 (SM-N9005; Android 5.0.2; gzip)";//Snapchat/9.10.0.0 (HTC One; Android 4.4.2#302626.7#19; gzip)";
NSString * const kUserAgentForAttestation = @"SafetyNet/7329000 (klte KOT49H); gzip";
NSString * const kURL                     = @"https://feelinsonice-hrd.appspot.com";
NSString * const kEventsURL               = @"https://sc-analytics.appspot.com/post_events";
NSString * const kSecret                  = @"iEk21fuwZApXlz93750dmW22pw389dPwOk";
NSString * const kStaticToken             = @"m198sOkJEn37DjqZ32lpRu76xmw288xSQ9";
NSString * const kBlobEncryptionKey       = @"M02cnQ51Ji97vwT4";
NSString * const kHashPattern             = @"0001110111101110001111010101111011010001001110011000110001000110";
NSString * const kBoundary                = @"Boundary+0xAbCdEfGbOuNdArY";
NSString * const kGMSVersion              = @"7329038";
NSString * const kAttestationAuth         = @"cp4craTcEr82Pdf5j8mwFKyb8FNZbcel";
NSString * const kAttestationURLSK        = @"[redacted]";
NSString * const kAttestationURLCasper    = @"http://attest.casper.io/attestation";
NSString * const kAPKDigest9_10           = @"JJShKOLH4YYjWZlJQ71A2dPTcmxbaMboyfo0nsKYayE=";
NSString * const kAPKDigest9_8            = @"vXCcGhQ7RfL1LUiE3F6vcNORNo7IFSOvuDBunK87mEI=";
NSString * const kAPKCertificateDigest    = @"Lxyq/KHtMNC044hj7vq+oOgVcR+kz3m4IlGaglnZWlg=";
NSString * const kDeviceToken1i           = @"dtoken1i";
NSString * const kDeviceToken1v           = @"dtoken1v";

NSString * const khfClientAuthToken = @"X-Snapchat-Client-Auth-Token";
NSString * const khfClientAuth      = @"X-Snapchat-Client-Auth";
NSString * const khfTimestamp       = @"X-Timestamp";
NSString * const khfContentType     = @"Content-Type";
NSString * const khfUserAgent       = @"User-Agent";
NSString * const khfAcceptLanguage  = @"Accept-Language";
NSString * const khfAcceptLocale    = @"Accept-Locale";
NSString * const khvLanguage        = @"en";
NSString * const khvLocale          = @"en_US";

NSString * const kepLogin                 = @"/loq/login";
NSString * const kepLogout                = @"/ph/logout";
NSString * const kepRegister              = @"/loq/register";
NSString * const kepRegisterUsername      = @"/loq/register_username";
NSString * const kepCaptchaGet            = @"/bq/get_captcha";
NSString * const kepCaptchaSolve          = @"/bq/solve_captcha";
NSString * const kepBlob                  = @"/bq/blob";
NSString * const kepChatMedia             = @"/bq/chat_media";
NSString * const kepPhoneVerify           = @"/bq/phone_verify";
NSString * const kepDeviceToken           = @"/loq/device_id";
NSString * const kepAllUpdates            = @"/loq/all_updates";
NSString * const kepConvoAuth             = @"/loq/conversation_auth_token";
NSString * const kepConversations         = @"/loq/conversations";
NSString * const kepConversation          = @"/loq/conversation";
NSString * const kepConvoClear            = @"/loq/clear_conversation";
NSString * const kepConvoPostMessages     = @"/loq/conversation_post_messages";
NSString * const kepFindFriends           = @"/ph/find_friends";
NSString * const kepFindNearby            = @"/bq/find_nearby_friends";
NSString * const kepFriendSearch          = @"/loq/friend_search";
NSString * const kepUserExists            = @"/bq/user_exists";
NSString * const kepFriends               = @"/bq/friend";
NSString * const kepFriendHide            = @"/loq/friend_hide";
NSString * const kepUpdateSnaps           = @"/bq/update_snaps";
NSString * const kepSharedDescription     = @"/shared/description";
NSString * const kepUpdateStories         = @"/bq/update_stories";
NSString * const kepUpdateUser            = @"/loq/update_user";
NSString * const kepUpload                = @"/ph/upload";
NSString * const kepRetrySend             = @"/loq/retry";
NSString * const kepSend                  = @"/loq/send";
NSString * const kepTyping                = @"/bq/chat_typing";
NSString * const kepPostStory             = @"/bq/post_story";
NSString * const kepPostStoryRetry        = @"/bq/retry_post_story";
NSString * const kepDeleteStory           = @"/bq/delete_story";
NSString * const kepMarkStoryViewed       = @"/update_stories";
NSString * const kepBestFriends           = @"/bq/bests";
NSString * const kepSetBestCount          = @"/bq/set_num_best_friends";
NSString * const kepClearFeed             = @"/ph/clear";
NSString * const kepSettings              = @"/bq/settings";
NSString * const kepFeatures              = @"/bq/update_feature_settings";
NSString * const kepSnaptag               = @"/bq/snaptag_download";
NSString * const kepCashEligible          = @"/cash/check_recipient_eligible";
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
NSString * const kepCashGenerateToken     = @"/cash/generate_access_token";// takes only username
NSString * const kepLocationData          = @"/loq/loc_data";
NSString * const kepDownloadSnaptagAvatar = @"/bq/download_profile_data";
NSString * const kepUploadSnaptagAvatar   = @"/bq/upload_profile_data";
NSString * const kepIPRouting             = @"/bq/ip_routing";
NSString * const kepSeenSuggestedFriends  = @"/bq/suggest_friend";

NSString * const kepGetStoryBlob      = @"/bq/story_blob?story_id=";
NSString * const kepGetStoryThumb     = @"/bq/story_thumbnail?story_id=";
NSString * const kepAuthStoryThumb    = @"/bq/auth_story_thumbnail";
NSString * const kepAuthStoryBlob     = @"/bq/auth_story_blob";


#pragma mark Discover
NSString * const kepDiscoverChannels = @"/discover/channel_list?region=";
NSString * const kepDiscoverIcons    = @"/discover/icons?icon="; // does not need to be signed in, returns image data
NSString * const kepDiscoverIntroVideos = @"/discover/intro_videos?publisher="; // &intro_video= &currentSession.resourceParamName=currentSession.resourceParamValue
NSString * const kepDiscoverSnaps       = @"/discover/dsnaps?edition_id="; // &snap_id= &hash= &publisher= &currentSession.resourceParamName=currentSession.resourceParamValue

#pragma mark Feature settings
NSString * const SKFeatureFrontFacingFlash = @"front_facing_flash";
NSString * const SKFeatureReplaySnaps      = @"replay_snaps";
NSString * const SKFeatureSmartFilters     = @"smart_filters";
NSString * const SKFeatureVisualFilters    = @"visual_filters";
NSString * const SKFeaturePowerSaveMode    = @"power_save_mode";
NSString * const SKFeatureSpecialText      = @"special_text";
NSString * const SKFeatureSwipeCashMode    = @"swipe_cash_mode";
NSString * const SKFeatureTravelMode       = @"travel_mode";









