//
//  NSArray+SnapchatKit.h
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/22/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (JSON)

/// Will never return nil.
@property (nonatomic, readonly) NSString *JSONString;
/// Will never return nil.
@property (nonatomic, readonly) NSArray *dictionaryValues;

@end


@interface NSArray (REST)
@property (nonatomic, readonly) NSString *recipientsString;
@end