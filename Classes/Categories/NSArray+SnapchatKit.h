//
//  NSArray+SnapchatKit.h
//  SnapchatKit
//
//  Created by Tanner on 5/22/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (JSON)

/** Will never return nil. */
- (NSString *)JSONString;

@end

@interface NSArray (REST)
- (NSString *)recipientsString;
@end