//
//  NSDictionary+SnapchatKit.h
//  SnapchatKit
//
//  Created by Tanner on 5/22/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

- (NSString *)JSONString;

@end


@interface NSDictionary (Util)
/** \c entryLimit must be greater than \c 0. */
- (NSArray *)split:(NSUInteger)entryLimit;

- (NSDictionary *)dictionaryByReplacingValuesForKeys:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryByReplacingKeysWithNewKeys:(NSDictionary *)oldKeysToNewKeys;

@end