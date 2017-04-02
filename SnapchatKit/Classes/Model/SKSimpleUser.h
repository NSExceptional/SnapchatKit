//
//  SKSimpleUser.h
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapchatKit-Constants.h"

#import "SKThing.h"

@interface SKSimpleUser : SKThing

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, readonly) NSString *userIdentifier;
@property (nonatomic, readonly) BOOL     addedIncoming;
@property (nonatomic, readonly) BOOL     ignoredLink;
@property (nonatomic, readonly) NSDate   *expiration;
/** When the request was accepted. */
@property (nonatomic, readonly) NSDate   *addedBack;
/** Self explainatory. Status of the relationship between you and this user. */
@property (nonatomic, readonly) SKFriendStatus friendStatus;

@end
