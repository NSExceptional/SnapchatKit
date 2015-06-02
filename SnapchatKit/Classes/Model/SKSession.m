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
    
    if (kDebugJSON) NSLog(@"Unknown story privacy type: %@", storyPrivacyString);
    return 0;
}

@implementation SKSession

- (id)init {
    NSAssert(nil, false);
    return nil;
}

+ (instancetype)sessionWithJSONResponse:(NSDictionary *)json {
    return [[SKSession alloc] initWithDictionary:json];
}

- (id)initWithDictionary:(NSDictionary *)json {
    
    NSDictionary *storiesResponse = json[@"stories_response"];
    NSDictionary *friendsResponse = json[@"friends_response"];
    NSDictionary *updatesResponse = json[@"updates_response"];
    NSDictionary *identity        = json[@"identity_check_response"];
    NSDictionary *features        = updatesResponse[@"feature_settings"];
    
    NSArray *friendStories = storiesResponse[@"friend_stories"];
    NSArray *myStories     = storiesResponse[@"my_stories"];
    //NSArray *groupStories  = storiesResponse[@"my_group_stories"];
    
    NSArray *friends       = friendsResponse[@"friends"];
    NSArray *added         = friendsResponse[@"added_friends"];
    NSArray *conversations = json[@"conversations_response"];
    
    
    self = [super initWithDictionary:json];
    if (self) {
        _backgroundFetchSecret = json[@"background_fetch_secret_key"];
        _bestFriendUsernames   = friendsResponse[@"bests"];
        
        _storiesDelta      = [storiesResponse[@"friend_stories_delta"] boolValue];
        _discoverSupported = ![json[@"discover"][@"compatibility"] isEqualToString:@"device_not_supported"];
        _emailVerified     = [identity[@"is_email_verified"] boolValue];
        
        // Friends
        NSMutableArray *temp = [NSMutableArray new];
        for (NSDictionary *friend in friends)
            [temp addObject:[[SKUser alloc] initWithDictionary:friend]];
        _friends = temp;
        
        // Added friends
        temp = [NSMutableArray new];
        for (NSDictionary *addedFriend in added)
            [temp addObject:[[SKAddedFriend alloc] initWithDictionary:addedFriend]];
        _addedFriends = temp;
        
        // Conversations
        temp = [NSMutableArray new];
        for (NSDictionary *convo in conversations)
            [temp addObject:[[SKConversation alloc] initWithDictionary:convo]];
        _conversations = temp;
        
        // Story collections
        temp = [NSMutableArray new];
        for (NSDictionary *collection in friendStories)
            [temp addObject:[[SKStoryCollection alloc] initWithDictionary:collection]];
        _stories = temp;
        
        // User stories
        temp = [NSMutableArray new];
        for (NSDictionary *story in myStories)
            [temp addObject:[[SKUserStory alloc] initWithDictionary:story]];
        _userStories = temp;
        
        // Group stories?
        _groupStories = @[];
        
        
        
        // Cash info
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
        _addedFriendsTimestamp      = [NSDate dateWithTimeIntervalSince1970:[updatesResponse[@"added_friends_timestamp"] doubleValue]/1000];
        _authToken                  = updatesResponse[@"auth_token"];
        _canSeeMatureContent        = [updatesResponse[@"can_view_mature_content"] boolValue];
        _countryCode                = updatesResponse[@"country_code"];
        _lastTimestamp              = [NSDate dateWithTimeIntervalSince1970:[updatesResponse[@"cash_provider"] doubleValue]/1000];
        _devicetoken                = updatesResponse[@"device_token"];
        _canSaveStoryToGallery      = [updatesResponse[@"enable_save_story_to_gallery"] boolValue];
        _canVideoTranscodingAndroid = [updatesResponse[@"enable_video_transcoding_android"] boolValue];
        _imageCaption               = [updatesResponse[@"image_caption"] boolValue];
        _isTwoFAEnabled             = [updatesResponse[@"is_two_fa_enabled"] boolValue];
        _lastAddressBookUpdateDate  = [NSDate dateWithTimeIntervalSince1970:[updatesResponse[@"last_address_book_updated_date"] doubleValue]/1000];
        _lastReplayedSnapDate       = [NSDate dateWithTimeIntervalSince1970:[updatesResponse[@"last_replayed_snap_timestamp"] doubleValue]/1000];
        _logged                     = [updatesResponse[@"logged"] boolValue];
        _mobileVerificationKey      = updatesResponse[@"mobile_verification_key"];
        _canUploadRawThumbnail      = [updatesResponse[@"raw_thumbnail_upload_enabled"] boolValue];
        _seenTooltips               = updatesResponse[@"seen_tooltips"];
        _shouldCallToVerifyNumber   = [updatesResponse[@"should_call_to_verify_number"] boolValue];
        _shouldTextToVerifyNumber   = [updatesResponse[@"should_send_text_to_verify_number"] boolValue];
        _snapchatPhoneNumber        = updatesResponse[@"snapchat_phone_number"];
        _studySettings              = updatesResponse[@"study_settings"];
        _targeting                  = updatesResponse[@"targeting"];
        _userIdentifier             = updatesResponse[@"user_id"];
        _enableVideoFilters         = [updatesResponse[@"video_filters_enabled"] boolValue];
        _QRPath                     = updatesResponse[@"qr_path"];
        
        // Preferences
        _enableNotificationSounds  = [updatesResponse[@"notification_sound_setting"] boolValue];
        _numberOfBestFriends       = [updatesResponse[@"number_of_best_friends"] integerValue];
        _privacyEveryone           = ![updatesResponse[@"snap_p"] boolValue];
        _isSearchableByPhoneNumber = [updatesResponse[@"searchable_by_phone_number"] boolValue];
        _storyPrivacy              = SKStoryPrivacyFromString(updatesResponse[@"story_privacy"]);
        
        // Features
        _enableFrontFacingFlash = [features[@"front_facing_flash"] boolValue];
        _enablePowerSaveMode    = [features[@"power_save_mode"] boolValue];
        _enableReplaySnaps      = [features[@"replay_snaps"] boolValue];
        _enableSmartFilters     = [features[@"smart_filters"] boolValue];
        _enableSpecialText      = [features[@"special_text"] boolValue];
        _enableSwipeCashMode    = [features[@"swipe_cash_mode"] boolValue];
        _enableVisualFilters    = [features[@"visual_filters"] boolValue];
    }
    
    [self.knownJSONKeys addObjectsFromArray:@[@"stories_response", @"friends_response", @"updates_response", @"identity_check_response", @"background_fetch_secret_key", @"discover"]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username=%@, mobile=%@, score=%lu, friends=%lu, added=%lu, stories=%lu, user stories=%lu>",
            NSStringFromClass(self.class), self.username, self.mobileNumber, self.score, self.friends.count,
            self.addedFriends.count, self.stories.count, self.userStories.count];
}

- (NSArray *)unread {
    NSMutableArray *unread = [NSMutableArray new];
    for (SKConversation *convo in self.conversations)
        [unread addObjectsFromArray:convo.pendingRecievedSnaps];
    
    return unread;
}

@end
