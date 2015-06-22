//
//  NSString+Encoding.h
//  SnapchatKit
//
//  Created by Tanner on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encoding)

- (NSString *)base64Encode;
- (NSString *)base64Decode;
- (NSString *)sha256Hash;
- (NSData *)sha256HashRaw;


/** Implementation of Snapchat's hashing algorithm. */
+ (NSString *)hashSC:(NSData *)first and:(NSData *)second;
+ (NSString *)hashSCString:(NSString *)first and:(NSString *)second;

+ (NSString *)hashHMac:(NSString *)data key:(NSString *)key;

- (NSString *)MD5Hash;

@end


@interface NSString (REST)

+ (NSString *)timestamp;
+ (NSString *)timestampFrom:(NSDate *)date;
+ (NSString *)queryStringWithParams:(NSDictionary *)params;

@end


@interface NSString (Regex)
- (NSString *)matchGroupAtIndex:(NSUInteger)idx forRegex:(NSString *)regex;
- (NSArray *)allMatchesForRegex:(NSString *)regex;
- (NSString *)textFromHTML;
- (NSString *)stringByReplacingMatchesForRegex:(NSString *)regex withString:(NSString *)replacement;
@end

@interface NSString (Snapchat)
+ (NSString *)SCIdentifierWith:(NSString *)first and:(NSString *)second;
@end

extern NSString * SKUniqueIdentifier();