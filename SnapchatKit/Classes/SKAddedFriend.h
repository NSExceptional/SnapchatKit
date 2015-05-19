//
//  SKAddedFriend.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSimpleUser.h"

@interface SKAddedFriend : SKSimpleUser

@property (nonatomic, readonly) SKAddSource addSourceType;
@property (nonatomic, readonly) NSDate      *timestamp;

@end
