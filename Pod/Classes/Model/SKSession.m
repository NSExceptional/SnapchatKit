//
//  SKSession.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
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

- (id)init {
    NSAssert(@"nil", false);
    return nil;
}

+ (instancetype)sessionWithJSONResponse:(NSDictionary *)json {
    return [[SKSession alloc] initWithDictionary:json];
}

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    
    NSDictionary *storiesResponse = json[@"stories_response"];
    NSDictionary *friendsResponse = json[@"friends_response"];
    NSDictionary *updatesResponse = json[@"updates_response"];
    NSDictionary *identity        = json[@"identity_check_response"];
    NSDictionary *features        = updatesResponse[@"feature_settings"];
    NSDictionary *discover        = json[@"discover"];
    NSDictionary *messagingGate   = json[@"messaging_gateway_info"];
    
    NSArray *friendStories = storiesResponse[@"friend_stories"];
    NSArray *myStories     = storiesResponse[@"my_stories"];
    //NSArray *groupStories  = storiesResponse[@"my_group_stories"];
    
    NSArray *friends       = friendsResponse[@"friends"];
    NSArray *added         = friendsResponse[@"added_friends"];
    NSArray *conversations = json[@"conversations_response"];
    
    if (self) {
        _backgroundFetchSecret = json[@"background_fetch_secret_key"];
        _bestFriendUsernames   = [NSMutableOrderedSet orderedSetWithArray:friendsResponse[@"bests"]];
        
        _storiesDelta      = [storiesResponse[@"friend_stories_delta"] boolValue];
        _emailVerified     = [identity[@"is_email_verified"] boolValue];
        _highAccuracyRequiredForNearby      = [identity[@"is_high_accuracy_required_for_nearby"] boolValue];
        _requirePhonePasswordConfirmed      = [identity[@"require_phone_password_confirmed"] boolValue];
        _redGearDurationMilliseconds        = [identity[@"red_gear_duration_millis"] doubleValue];
        _suggestedFriendFetchThresholdHours = [identity[@"suggested_friend_fetch_threshold_hours"] integerValue];
        
        _messagingGatewayAuth   = messagingGate[@"gateway_auth_token"];
        _messagingGatewayServer = messagingGate[@"gateway_server"];
        
        // Discover
        _discoverSupported          = [discover[@"compatibility"] isEqualToString:@"supported"];// alternative is @"device_not_supported"
        _discoverSharingEnabled     = [discover[@"sharing_enabled"] boolValue];
        _discoverGetChannels        = discover[@"get_channels"];
        _discoverResourceParamName  = discover[@"resource_parameter_name"];
        _discoverResourceParamValue = discover[@"resource_parameter_value"];
        _discoverVideoCatalog       = discover[@"video_catalog"];
        _sponsored                  = json[@"sponsored"];
        
        // Friends
        NSMutableOrderedSet *temp = [NSMutableOrderedSet orderedSet];
        for (NSDictionary *friend in friends)
            [temp addObject:[[SKUser alloc] initWithDictionary:friend]];
        _friends = temp;
        
        // Added friends
        temp = [NSMutableOrderedSet orderedSet];
        for (NSDictionary *addedFriend in added)
            [temp addObject:[[SKAddedFriend alloc] initWithDictionary:addedFriend]];
        _addedFriends = temp;
        
        // Conversations
        temp = [NSMutableOrderedSet orderedSet];
        for (NSDictionary *convo in conversations)
            [temp addObject:[[SKConversation alloc] initWithDictionary:convo]];
        _conversations = temp;
        
        // Story collections
        temp = [NSMutableOrderedSet orderedSet];
        for (NSDictionary *collection in friendStories)
            [temp addObject:[[SKStoryCollection alloc] initWithDictionary:collection]];
        _stories = temp;
        
        // User stories
        temp = [NSMutableOrderedSet orderedSet];
        for (NSDictionary *story in myStories)
            [temp addObject:[[SKUserStory alloc] initWithDictionary:story]];
        _userStories = temp;
        
        // Group stories?
        _groupStories = [NSMutableOrderedSet new];
        
        // Added me but not added back
        
        temp = [NSMutableOrderedSet orderedSet];
        for (SKSimpleUser *user in self.addedFriends)
            if (![self.friends containsObject:user])
                [temp addObject:user];
        // Reverse so that most recent requests are at the front
        _pendingRequests = temp;
        
        
        // Cash info //
        // Possible values may be "NO_VERIFIED_PHONE" or "1"
        _canUseCash             = [updatesResponse[@"allowed_to_use_cash"] boolValue];
        _isCashActive           = [updatesResponse[@"is_cash_active"] boolValue];
        _cashCustomerIdentifier = updatesResponse[@"cash_customer_id"];
        _cashClientProperties   = updatesResponse[@"client_properties"];
        _cashProvider           = updatesResponse[@"cash_provider"];
        
        // Basic user info
        _username     = updatesResponse[@"username"];
        _email        = updatesResponse[@"email"];
        _mobileNumber = updatesResponse[@"mobile"];
        _recieved     = [updatesResponse[@"recieved"] integerValue];
        _sent         = [updatesResponse[@"sent"] integerValue];
        _score        = [updatesResponse[@"score"] integerValue];
        _recents      = updatesResponse[@"recents"];
        _requests     = updatesResponse[@"requests"];
        
        // Account information
        _addedFriendsTimestamp         = [NSDate dateWithTimeIntervalSince1970:[updatesResponse[@"added_friends_timestamp"] doubleValue]/1000];
        _authToken                     = updatesResponse[@"auth_token"];
        _canSeeMatureContent           = [updatesResponse[@"can_view_mature_content"] boolValue];
        _countryCode                   = updatesResponse[@"country_code"] ?: @"US";
        _lastTimestamp                 = [NSDate dateWithTimeIntervalSince1970:[updatesResponse[@"cash_provider"] doubleValue]/1000];
        _devicetoken                   = updatesResponse[@"device_token"];
        _canSaveStoryToGallery         = [updatesResponse[@"enable_save_story_to_gallery"] boolValue];
        _canVideoTranscodingAndroid    = [updatesResponse[@"enable_video_transcoding_android"] boolValue];
        _imageCaption                  = [updatesResponse[@"image_caption"] boolValue];
        _requireRefreshingProfileMedia = [updatesResponse[@"require_refreshing_profile_media"] boolValue];
        _isTwoFAEnabled                = [updatesResponse[@"is_two_fa_enabled"] boolValue];
        _lastAddressBookUpdateDate     = [NSDate dateWithTimeIntervalSince1970:[updatesResponse[@"last_address_book_updated_date"] doubleValue]/1000];
        _lastReplayedSnapDate          = [NSDate dateWithTimeIntervalSince1970:[updatesResponse[@"last_replayed_snap_timestamp"] doubleValue]/1000];
        _logged                        = [updatesResponse[@"logged"] boolValue];
        _mobileVerificationKey         = updatesResponse[@"mobile_verification_key"];
        _canUploadRawThumbnail         = [updatesResponse[@"raw_thumbnail_upload_enabled"] boolValue];
        _seenTooltips                  = updatesResponse[@"seen_tooltips"];
        _shouldCallToVerifyNumber      = [updatesResponse[@"should_call_to_verify_number"] boolValue];
        _shouldTextToVerifyNumber      = [updatesResponse[@"should_send_text_to_verify_number"] boolValue];
        _snapchatPhoneNumber           = updatesResponse[@"snapchat_phone_number"];
        _studySettings                 = updatesResponse[@"study_settings"];
        _targeting                     = updatesResponse[@"targeting"];
        _userIdentifier                = updatesResponse[@"user_id"];
        _videoFiltersEnabled           = [updatesResponse[@"video_filters_enabled"] boolValue];
        _QRPath                        = updatesResponse[@"qr_path"];
        
        // Preferences
        _enableNotificationSounds  = [updatesResponse[@"notification_sound_setting"] boolValue];
        _numberOfBestFriends       = [updatesResponse[@"number_of_best_friends"] integerValue];
        _privacyEveryone           = ![updatesResponse[@"snap_p"] boolValue];
        _isSearchableByPhoneNumber = [updatesResponse[@"searchable_by_phone_number"] boolValue];
        _storyPrivacy              = SKStoryPrivacyFromString(updatesResponse[@"story_privacy"]);
        
        // Features
        _enableFrontFacingFlash = [features[SKFeatureSettings.frontFacingFlash] boolValue];
        _enablePowerSaveMode    = [features[SKFeatureSettings.powerSaveMode] boolValue];
        _enableReplaySnaps      = [features[SKFeatureSettings.replaySnaps] boolValue];
        _enableSmartFilters     = [features[SKFeatureSettings.smartFilters] boolValue];
        _enableSpecialText      = [features[SKFeatureSettings.specialText] boolValue];
        _enableSwipeCashMode    = [features[SKFeatureSettings.swipeCashMode] boolValue];
        _enableVisualFilters    = [features[SKFeatureSettings.visualFilters] boolValue];
        _enableTravelMode       = [features[SKFeatureSettings.travelMode] boolValue];
    }
    
    [[self class] addKnownJSONKeys:@[@"stories_response", @"friends_response", @"updates_response", @"identity_check_response", @"conversations_response",
                                     @"background_fetch_secret_key", @"discover", @"messaging_gateway_info", @"sponsored"]];
    
    [[self class] addKnownJSONKeys:@[@"current_timestamp",@"logged",@"industries",@"story_privacy",@"snap_p",@"should_call_to_verify_number",
                                     @"mobile_verification_key",@"score",@"added_friends_timestamp",@"auth_token",@"last_address_book_updated_date",
                                     @"is_cash_active",@"image_caption",@"enable_lenses_android",@"temp",@"requests",@"feature_settings",@"email",
                                     @"allowed_to_use_cash",@"searchable_by_phone_number",@"number_of_best_friends",@"is_two_fa_enabled",
                                     @"birthday",@"seen_tooltips",@"gaussian_blur_level_android",@"device_token",@"cash_customer_id",@"client_properties",@"username",
                                     @"snapchat_phone_number",@"verified_shared_publications",@"mobile",@"raw_thumbnail_upload_enabled",@"video_filters_enabled",@"sent",
                                     @"recents",@"user_id",@"received",@"should_send_text_to_verify_number",@"notification_sound_setting",@"country_code",
                                     @"require_refreshing_profile_media",@"can_view_mature_content",@"enable_video_transcoding_android",@"study_settings",@"cash_provider",
                                     @"enable_save_story_to_gallery",@"targeting",@"contacts_resync_request",@"qr_path"]];
    
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


@end


@implementation SKSession (Friends)

- (SKUser *)userWithUsername:(NSString *)username {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@", @"username", username];
    return [self.friends filteredOrderedSetUsingPredicate:filter].firstObject;
}

- (SKConversation *)conversationWithUser:(NSString *)username {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@", @"recipient", username];
    return [self.conversations filteredOrderedSetUsingPredicate:filter].firstObject;
}

@end


@implementation SKSession (Stories)

- (NSArray *)sharedStories {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@", @"isSharedStory", @YES];
    return [self.stories filteredOrderedSetUsingPredicate:filter].array;
}

@end