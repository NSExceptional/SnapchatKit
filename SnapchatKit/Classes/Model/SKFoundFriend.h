//
//  SKFoundFriend.h
//  SnapchatKit
//
//  Created by Tanner on 6/14/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"

@interface SKFoundFriend : SKThing

@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) BOOL     isPrivate;

@end
