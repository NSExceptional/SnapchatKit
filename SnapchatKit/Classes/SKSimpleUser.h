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

+ (instancetype)userFromResponse:(NSDictionary *)json;

@property (nonatomic, readonly) NSString  *username;
@property (nonatomic, readonly) NSString  *displayName;
@property (nonatomic, readonly) BOOL      addedIncoming;
@property (nonatomic, readonly) NSDate    *expiration;
@property (nonatomic, readonly) NSInteger type;

@end
