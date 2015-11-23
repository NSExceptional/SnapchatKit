//
//  SKAddedFriend.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSimpleUser.h"

/** Appears in the \c addedFriends property of \c SKSession. */
@interface SKAddedFriend : SKSimpleUser

/** ie "Added you back" */
@property (nonatomic, readonly) NSString    *addSource;
/** How they were added. */
@property (nonatomic, readonly) SKAddSource addSourceType;
/** When they were added. */
@property (nonatomic, readonly) NSDate      *timestamp;
/** The number of pending snaps you have from this user. */
@property (nonatomic, readonly) NSUInteger  pendingSnaps;

@end
