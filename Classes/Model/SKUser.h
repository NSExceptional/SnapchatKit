//
//  SKUser.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSimpleUser.h"

@interface SKUser : SKSimpleUser

/** See http://i.imgur.com/PfFbw59.jpg */
@property (nonatomic, readonly) NSString *friendmoji;
@property (nonatomic, readonly) NSString *venue;
/** \c nil if the user is not a shared story. */
@property (nonatomic, readonly) NSString *sharedStoryIdentifier;

/** NO if your stories are hidden from this user in "who can see my stories?". */
@property (nonatomic, readonly) BOOL canSeeCustomStories;
@property (nonatomic, readonly) BOOL needsLove;
@property (nonatomic, readonly) BOOL isSharedStory;
@property (nonatomic, readonly) BOOL isLocalStory;
@property (nonatomic, readonly) BOOL hasCustomDescription;
/** Undocumented. */
@property (nonatomic, readonly) BOOL decayThumbnail;
/** Undocumented. */
@property (nonatomic, readonly) NSDate *timestamp;

@end