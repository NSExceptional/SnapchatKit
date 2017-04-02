//
//  SKSession.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSession.h"
#import "SKStoryCollection.h"
#import "SKUserStory.h"
#import "SKUser.h"
#import "SKAddedFriend.h"
#import "SKConversation.h"
#import "SKSnap.h"
#import "SKMessage.h"
#import "SKTrophy.h"

SKStoryPrivacy SKStoryPrivacyFromString(NSString *storyPrivacyString) {
    if ([storyPrivacyString isEqualToString:@"EVERYONE"])
        return SKStoryPrivacyEveryone;
    if ([storyPrivacyString isEqualToString:@"FRIENDS"])
        return SKStoryPrivacyFriends;
    if ([storyPrivacyString isEqualToString:@"CUSTOM"])
        return SKStoryPrivacyCustom;
    
    if (kDebugJSON) SKLog(@"Unknown story privacy type: %@", storyPrivacyString);
    return 0;
}

@implementation SKSession

+ (instancetype)sessionWithJSONResponse:(NSDictionary *)json {
    return [[SKSession alloc] initWithDictionary:json];
}

- (id)initWithDictionary:(NSDictionary *)json error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:json error:error];
    if (self) {
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        [_conversations.array makeObjectsPerformSelector:@selector(setRecipient:) withObject:self.username];
        
        // Group stories?
        _groupStories = [NSMutableOrderedSet new];
        
        // Added me but not added back
        NSMutableOrderedSet *temp = [NSMutableOrderedSet orderedSet];
        for (SKSimpleUser *user in self.addedFriends)
            if (![self.friends containsObject:(SKUser *)user])
                [temp addObject:user];
        // Reverse so that most recent requests are at the front
        _pendingRequests = temp;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username=%@, mobile=%@, score=%lu, friends=%lu, added=%lu, stories=%lu, user stories=%lu>",
            NSStringFromClass(self.class), self.username, self.mobileNumber, (unsigned long)self.score, (unsigned long)self.friends.count,
            (unsigned long)self.addedFriends.count, (unsigned long)self.stories.count, (unsigned long)self.userStories.count];
}

- (NSArray *)unread {
    NSMutableArray *unread = [NSMutableArray new];
    for (SKConversation *convo in self.conversations)
        [unread addObjectsFromArray:convo.pendingRecievedSnaps];
    
    return unread;
}

- (SKSession *)mergeWithOldSession:(SKSession *)oldSession {
    NSParameterAssert(oldSession);
    
    [oldSession.friends minusOrderedSet:self.friends];
    [self.friends addObjectsFromArray:oldSession.friends.array];
    
    [oldSession.addedFriends minusOrderedSet:self.addedFriends];
    [self.addedFriends addObjectsFromArray:oldSession.addedFriends.array];
    
    // No need to do best friend usernames or pending requests
    
    [oldSession.conversations minusOrderedSet:self.conversations];
    [self.conversations addObjectsFromArray:oldSession.conversations.array];
    
    [oldSession.stories minusOrderedSet:self.stories];
    [self.stories addObjectsFromArray:oldSession.stories.array];
    
    [oldSession.userStories minusOrderedSet:self.userStories];
    [self.userStories addObjectsFromArray:oldSession.userStories.array];
    
    [oldSession.groupStories minusOrderedSet:self.groupStories];
    [self.groupStories addObjectsFromArray:oldSession.groupStories.array];
    
    return self;
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"username": @"updates_response.username",
             @"backgroundFetchSecret": @"background_fetch_secret_key",
             @"bestFriendUsernames": @"friends_response.bests", //
             @"storiesDelta": @"stories_response.friend_stories_delta",
             @"emailVerified": @"identity_check_response.is_email_verified",
             @"highAccuracyRequiredForNearby": @"identity_check_response.is_high_accuracy_required_for_nearby",
             @"requirePhonePasswordConfirmed": @"identity_check_response.require_phone_password_confirmed",
             @"redGearDurationMilliseconds": @"identity_check_response.red_gear_duration_millis",
             @"suggestedFriendFetchThresholdHours": @"identity_check_response.suggested_friend_fetch_threshold_hours",
             @"messagingGatewayAuth": @"messaging_gateway_info.gateway_auth_token",
             @"messagingGatewayServer": @"messaging_gateway_info.gateway_server",
             @"discoverSupported": @"discover.compatibility", //
             @"discoverSharingEnabled": @"discover.sharing_enabled",
             @"discoverGetChannels": @"discover.get_channels",
             @"discoverResourceParamName": @"discover.resource_parameter_name",
             @"discoverResourceParamValue": @"discover.resource_parameter_value",
             @"discoverVideoCatalog": @"discover.video_catalog",
             @"sponsored": @"sponsored",
             @"friendsSyncToken": @"friends_response.friends_sync_token",
             @"friendsSyncType": @"friends_response.friends_sync_type",
             @"friends": @"friends_response.friends",
             @"addedFriends": @"friends_response.added_friends",
             @"conversations": @"conversations_response",
             @"stories": @"stories_response.friend_stories",
             @"userStories": @"stories_response.my_stories",
             @"groupStories": @"stories_response.my_group_stories", // other stories, pending requests
             @"canUseCash": @"updates_response.allowed_to_use_cash",
             @"isCashActive": @"updates_response.is_cash_active",
             @"cashCustomerIdentifier": @"updates_response.cash_customer_id",
             @"clientProperties": @"updates_response.client_properties",
             @"cashProvider": @"updates_response.cash_provider",
             @"email": @"updates_response.email",
             @"mobileNumber": @"updates_response.mobile",
             @"recieved": @"updates_response.recieved",
             @"sent": @"updates_response.sent",
             @"score": @"updates_response.score",
             @"recents": @"updates_response.recents",
             @"requests": @"updates_response.requests",
             @"addedFriendsTimestamp": @"updates_response.added_friends_timestamp",
             @"authToken": @"updates_response.auth_token",
             @"canSeeMatureContent": @"updates_response.can_view_mature_content",
             @"countryCode": @"updates_response.country_code",
             @"devicetoken": @"updates_response.device_token",
             @"canSaveStoryToGallery": @"updates_response.enable_save_story_to_gallery",
             @"canVideoTranscodingAndroid": @"updates_response.enable_video_transcoding_android",
             @"imageCaption": @"updates_response.image_caption",
             @"requireRefreshingProfileMedia": @"updates_response.require_refreshing_profile_media",
             @"isTwoFAEnabled": @"updates_response.is_two_fa_enabled",
             @"lastAddressBookUpdateDate": @"updates_response.last_address_book_updated_date",
             @"lastReplayedSnapDate": @"updates_response.last_replayed_snap_timestamp",
             @"logged": @"updates_response.logged",
             @"mobileVerificationKey": @"updates_response.mobile_verification_key",
             @"canUploadRawThumbnail": @"updates_response.raw_thumbnail_upload_enabled",
             @"seenTooltips": @"updates_response.seen_tooltips",
             @"shouldCallToVerifyNumber": @"updates_response.should_call_to_verify_number",
             @"shouldTextToVerifyNumber": @"updates_response.should_send_text_to_verify_number",
             @"snapchatPhoneNumber": @"updates_response.snapchat_phone_number",
             @"studySettings": @"updates_response.study_settings",
             @"targeting": @"updates_response.targeting",
             @"userIdentifier": @"updates_response.user_id",
             @"videoFiltersEnabled": @"updates_response.video_filters_enabled",
             @"QRPath": @"updates_response.qr_path",
             @"enableNotificationSounds": @"updates_response.notification_sound_setting",
             @"numberOfBestFriends": @"updates_response.number_of_best_friends",
             @"privacyEveryone": @"updates_response.snap_p",
             @"isSearchableByPhoneNumber": @"updates_response.searchable_by_phone_number",
             @"storyPrivacy": @"updates_response.story_privacy",
             @"enableFrontFacingFlash": @"updates_response.feature_settings.front_facing_flash",
             @"enablePowerSaveMode": @"updates_response.feature_settings.power_save_mode",
             @"enableReplaySnaps": @"updates_response.feature_settings.replay_snaps",
             @"enableSmartFilters": @"updates_response.feature_settings.smart_filters",
             @"enableSpecialText": @"updates_response.feature_settings.special_text",
             @"enableSwipeCashMode": @"updates_response.feature_settings.swipe_cash_mode",
             @"enableVisualFilters": @"updates_response.feature_settings.visual_filters",
             @"enableTravelMode": @"updates_response.feature_settings.travel_mode",
             @"lastCheckedTrophies": @"identity_check_response.last_checked_trophies_timestamp",
             @"trophyCase": @"identity_check_response.trophy_case.response",
             @"serverInfo": @"server_info",
             @"checksums": @"server_info.response_checksum",
             @"ringerSoundOn": @"updates_response.ringing_sound_setting",
             @"payReplaySnaps": @"updates_response.feature_settings.pay_replay_snaps",
             @"IAPEnabledCurrencies": @"updates_response.enabled_iap_currencies",
             @"enabledLensStoreCurrencies": @"updates_response.enabled_lens_store_currencies",
             @"friendmojis": @"updates_response.friendmoji_dict",
             @"friendmojisReadOnly": @"updates_response.friendmoji_read_only_dict",
             @"friendmojisMutable": @"updates_response.friendmoji_mutable_dict",
             @"industries": @"updates_response.industries",
             @"enableGuggenheim": @"updates_response.feature_settings.guggenheim_enabled",
             @"lensStoreEnabled": @"updates_response.feature_settings.lens_store_available",
             @"QRCodeEnabled": @"updates_response.feature_settings.qrcode_enabled",
             @"prefetchStoreLensesEnabled": @"updates_response.feature_settings.is_prefetch_for_store_lenses_enabled",
             @"payReplaySnaps": @"updates_response.feature_settings.pay_replay_snaps",
             @"featuresNotUserConfigurable": @"updates_response.features_not_user_configurable"};
}

+ (NSArray *)ignoredJSONKeyPathPrefixes {
    static NSArray *ignored = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ignored = @[@"updates_response.friendmoji_dict", @"updates_response.friendmoji_read_only_dict",
                    @"updates_response.friendmoji_mutable_dict", @"ad_placement_metadata",
                    @"updates_response.study_settings", @"sponsored", @"updates_response.client_properties",
                    @"updates_response.targeting", @"messaging_gateway_info", @"updates_response.gaussian_blur_level_android",
                    @"updates_response.enable_lenses_android", @"updates_response.enable_recording_hint_android",
                    @"server_info", @"updates_response.enable_fast_frame_rate_camera_initialization_android"];
    });
    
    return ignored;
}

+ (NSValueTransformer *)bestFriendUsernamesJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *bests, BOOL *success, NSError *__autoreleasing *error) {
        return [NSMutableOrderedSet orderedSetWithArray:bests];
    } reverseBlock:^id(NSMutableOrderedSet *bests, BOOL *success, NSError *__autoreleasing *error) {
        return bests.array;
    }];
}

MTLTransformPropertyDate(addedFriendsTimestamp)
MTLTransformPropertyDate(lastAddressBookUpdateDate)
MTLTransformPropertyDate(lastReplayedSnapDate)
MTLTransformPropertyDate(lastCheckedTrophies)

+ (NSValueTransformer *)friendsJSONTransformer { return [self sk_modelMutableOrderedSetTransformerForClass:[SKUser class]]; }
+ (NSValueTransformer *)addedFriendsJSONTransformer { return [self sk_modelMutableOrderedSetTransformerForClass:[SKAddedFriend class]]; }
+ (NSValueTransformer *)conversationsJSONTransformer { return [self sk_modelMutableOrderedSetTransformerForClass:[SKConversation class]]; }
+ (NSValueTransformer *)storiesJSONTransformer { return [self sk_modelMutableOrderedSetTransformerForClass:[SKStoryCollection class]]; }
+ (NSValueTransformer *)userStoriesJSONTransformer { return [self sk_modelMutableOrderedSetTransformerForClass:[SKUserStory class]]; }
+ (NSValueTransformer *)groupStoriesJSONTransformer { return [self sk_modelMutableOrderedSetTransformerForClass:[SKStory class]]; }
+ (NSValueTransformer *)trophyCaseJSONTransformer { return [self sk_modelMutableOrderedSetTransformerForClass:[SKTrophy class]]; }
+ (NSValueTransformer *)ringerSoundOnJSONTransformer { return [self sk_onOffTransformer]; }
+ (NSValueTransformer *)enableNotificationSoundsJSONTransformer { return [self sk_onOffTransformer]; }

+ (NSValueTransformer *)storyPrivacyJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *p, BOOL *success, NSError *__autoreleasing *error) {
        return @(SKStoryPrivacyFromString(p));
    } reverseBlock:^id(NSNumber *p, BOOL *success, NSError *__autoreleasing *error) {
        return SKStringFromStoryPrivacy(p.integerValue);
    }];
}

+ (NSValueTransformer *)privacyEveryoneJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSNumber *val, BOOL *success, NSError *__autoreleasing *error) {
        return  @(!val.boolValue);
    } reverseBlock:^id(NSNumber *val, BOOL *success, NSError *__autoreleasing *error) {
        return  @(!val.boolValue);
    }];
}

+ (NSValueTransformer *)discoverSupportedJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{@"supported": @YES, @"device_not_supported": @NO} defaultValue:@NO reverseDefaultValue:@"device_not_supported"];
}

+ (NSValueTransformer *)canUseCashJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{@"OK": @YES, @"NO_VERIFIED_PHONE": @NO} defaultValue:@NO reverseDefaultValue:@"NO_VERIFIED_PHONE"];
}

@end


@implementation SKSession (Friends)

- (SKSimpleUser *)userWithUsername:(NSString *)username {
    return [self friendWithUsername:username] ?: [self addedFriendWithUsername:username];
}

- (SKAddedFriend *)addedFriendWithUsername:(NSString *)username {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@", @"username", username];
    return [self.addedFriends filteredOrderedSetUsingPredicate:filter].firstObject;
}

- (SKUser *)friendWithUsername:(NSString *)username {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@", @"username", username];
    return [self.friends filteredOrderedSetUsingPredicate:filter].firstObject;
}

- (SKConversation *)conversationWithUser:(NSString *)username {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@", @"sender", username];
    return [self.conversations filteredOrderedSetUsingPredicate:filter].firstObject;
}

@end


@implementation SKSession (Stories)

- (NSArray *)sharedStories {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@", @"isSharedStory", @YES];
    return [self.stories filteredOrderedSetUsingPredicate:filter].array;
}

@end