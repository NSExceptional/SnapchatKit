//
//  SKClient+Friends.h
//  SnapchatKit
//
//  Created by Tanner on 5/26/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKClient.h"

@class CLLocation;

@interface SKClient (Friends)

/** Adds the users in \e toAdd as friends, and unfriends the users in \e toUnfriend.
 @param toAdd An array of username strings of users to add. Doesn't matter if they're already in your friends.
 @param toUnfriend An array of username strings of users to un-friend. Doesn't matter if they're not already in your friends.
 @param completion Takes an error, if any. */
- (void)addFriends:(NSArray *)toAdd removeFriends:(NSArray *)toUnfriend completion:(ErrorBlock)completion;
/** Adds \c username as a friend.
 @param username The user to add.
 @param completion Takes an error, if any, and an \c SKUser object, which is automatically added to \c [SKClient sharedClient].currentSession.friends. */
- (void)addFriend:(NSString *)username completion:(ResponseBlock)completion;
/** Use this to add back a user who has added you as a friend. Sort of like accepting a friend request.
 @discussion This only affects the "added by" string the other user will see.
 @param username The username of the user user to add back.
 @param completion Takes an error, if any, and an \c SKUser object, which is automatically added to \c [SKClient sharedClient].currentSession.friends. */
- (void)addFriendBack:(NSString *)username completion:(ResponseBlock)completion;
/** Unfriends \c username.
 @param username The username of the user to unfriend.
 @param completion Takes an error, if any, and an \c SKUser object, which is automatically removed from \c [SKClient sharedClient].currentSession.friends. */
- (void)unfriend:(NSString *)username completion:(ResponseBlock)completion;

/** Finds friends given phone numbers and names.
 @discussion \c friends is a number->name map, where "name" is the desired screen name of that friend and "number" is their phone number.
 The names given will be used as display names for any usernames found.
 @param friends a dictionary with phone number strings as the keys and name strings as the values.
 @param completion Takes an error, if any, and an array of \c SKFoundFriend objects.
 */
- (void)findFriends:(NSDictionary *)friends completion:(ArrayBlock)completion;
/** Finds nearby snapchatters who are also looking for nearby snapchatters.
 @param location The location to search from.
 @param meters The radius to find nearby snapchatters at \c location. Defaults to \c 10.
 @param milliseconds The total poll duration so far. If you're polling in a for-loop for example, pass the time in milliseconds since you started polling. This has been guess-work, but I think it's right.
 @param completion Takes an error, if any, and an array of \c SKNearbyUser objects. */
- (void)findFriendsNear:(CLLocation *)location accuracy:(CGFloat)meters pollDurationSoFar:(NSUInteger)milliseconds completion:(ArrayBlock)completion;

/** Not sure what this is for. */
- (void)searchFriend:(NSString *)query completion:(ResponseBlock)completion;
/** Checks to see whether \c username is a registered username.
 @param completion Takes an error, if any, and a \c \BOOL indicating if the username is registered. Defaults to \c NO if there was an error. */
- (void)userExists:(NSString *)username completion:(BooleanBlock)completion;
/** Updates the display name for one of your friends.
 @param friend The username to give the new display name to.
 @param displayName The new display name.
 @param completion Takes an error, if any. */
- (void)updateDisplayNameForUser:(NSString *)friend newName:(NSString *)displayName completion:(ErrorBlock)completion;
/** Blocks \c username.
 @param username The username of the user to block.
 @param completion Takes an error, if any. */
- (void)blockUser:(NSString *)username completion:(ErrorBlock)completion;

/** This appears to be for an upcoming feature: suggested friends?
 @param usernames I assume this is for usernames; it's always been empty.
 @param seen Whether to mark as seen.
 @param completion Takes an error, if any. */
- (void)seenSuggestedFriends:(NSArray *)usernames seen:(BOOL)seen completion:(ErrorBlock)completion;


/** Depricated API call. Best friends will be empty. Callback dictionary is in the following format:
 @code
 {
     username = {
         "best_friends" = ();
         score = 12819;
     };
     "user_name" =     {
         "best_friends" = ();
         score = 58886;
     };
 }
 @endcode */
- (void)bestFriendsOfUsers:(NSArray *)usernames completion:(DictionaryBlock)completion;
@end