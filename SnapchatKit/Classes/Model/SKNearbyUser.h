//
//  SKNearbyUser.h
//  SnapchatKit
//
//  Created by Tanner Bennett on 7/3/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKThing.h"

/** Passed to the callback of \c -[SKClient findFriendsNear:accuracy:pollDurationSoFar:completion: */
@interface SKNearbyUser : SKThing

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *identifier;

@end
