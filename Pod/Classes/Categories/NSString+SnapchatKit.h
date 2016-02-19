//
//  NSString+Encoding.h
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Util)

/// Joins other strings into a single string with the receiver in between each.
- (NSString *)join:(NSArray *)otherStrings;

@end

@interface NSString (Encoding)

@property (nonatomic, readonly) NSString *base64Encoded;
@property (nonatomic, readonly) NSString *base64URLEncoded;
@property (nonatomic, readonly) NSString *base64Decoded;
@property (nonatomic, readonly) NSData   *base64DecodedData;

@property (nonatomic, readonly) NSString *MD5Hash;
@property (nonatomic, readonly) NSString *sha256Hash;
@property (nonatomic, readonly) NSData   *sha256HashData;


/** Implementation of Snapchat's hashing algorithm. */
+ (NSString *)hashSC:(NSData *)first and:(NSData *)second;
+ (NSString *)hashSCString:(NSString *)first and:(NSString *)second;

+ (NSData *)hashHMac:(NSString *)data key:(NSString *)key;
+ (NSString *)hashHMacToString:(NSString *)data key:(NSString *)key;

@end


@interface NSString (REST)

+ (NSString *)timestamp;
+ (NSString *)timestampInSeconds;
+ (NSString *)timestampFrom:(NSDate *)date;
+ (NSString *)queryStringWithParams:(NSDictionary *)params;
+ (NSString *)queryStringWithParams:(NSDictionary *)params URLEscapeValues:(BOOL)escapeValues;

@end


@interface NSString (Regex)
@property (nonatomic, readonly) NSString *textFromHTML;
- (NSString *)matchGroupAtIndex:(NSUInteger)idx forRegex:(NSString *)regex;
- (NSArray *)allMatchesForRegex:(NSString *)regex;
- (NSString *)stringByReplacingMatchesForRegex:(NSString *)regex withString:(NSString *)replacement;
@end

@interface NSString (Snapchat)
+ (NSString *)SCIdentifierWith:(NSString *)first and:(NSString *)second;
@end

extern NSString * SKMediaIdentifier(NSString *sender);
extern NSString * SKUniqueIdentifier();