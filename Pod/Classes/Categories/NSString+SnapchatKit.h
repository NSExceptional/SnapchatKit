//
//  NSString+Encoding.h
//  SnapchatKit
//
//  Created by Tanner on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encoding)

- (NSData *)base64DecodedData;
- (NSString *)base64Encode;
- (NSString *)base64Decode;
- (NSString *)sha256Hash;
- (NSData *)sha256HashRaw;


/** Implementation of Snapchat's hashing algorithm. */
+ (NSString *)hashSC:(NSData *)first and:(NSData *)second;
+ (NSString *)hashSCString:(NSString *)first and:(NSString *)second;

+ (NSData *)hashHMac:(NSString *)data key:(NSString *)key;
+ (NSString *)hashHMacToString:(NSString *)data key:(NSString *)key;

- (NSString *)MD5Hash;

@end


@interface NSString (REST)
+ (NSString *)timestamp;
+ (NSString *)timestampFrom:(NSDate *)date;
+ (NSString *)queryStringWithParams:(NSDictionary *)params;
+ (NSString *)queryStringWithParams:(NSDictionary *)params URLEscapeValues:(BOOL)escapeValues;

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

extern NSString * SKMediaIdentifier(NSString *sender);
extern NSString * SKUniqueIdentifier();