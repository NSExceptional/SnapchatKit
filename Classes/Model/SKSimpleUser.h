//
//  SKSimpleUser.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
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
/** Whether anyone or only friends can send snaps to this user. */
@property (nonatomic, readonly) SKSnapPrivacy privacy;

@end
