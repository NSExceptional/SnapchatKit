//
//  NSString+SnapchatKit.h
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSString+Networking.h"


@interface NSString (SnapchatKit)

/** Implementation of Snapchat's hashing algorithm. */
+ (NSString *)hashSC:(NSData *)first and:(NSData *)second;
+ (NSString *)hashSCString:(NSString *)first and:(NSString *)second;

+ (NSString *)timestampInSeconds;

+ (NSString *)SCIdentifierWith:(NSString *)first and:(NSString *)second;

@end

extern NSString * SKMediaIdentifier(NSString *sender);
extern NSString * SKUniqueIdentifier();