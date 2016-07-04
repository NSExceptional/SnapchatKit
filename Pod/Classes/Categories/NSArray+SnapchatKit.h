//
//  NSArray+SnapchatKit.h
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/22/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSArray+Networking.h"


@interface NSArray (SnapchatKit)
/// Will never return nil.
@property (nonatomic, readonly) NSArray *dictionaryValues;
@property (nonatomic, readonly) NSArray *recipientsString;

@end
