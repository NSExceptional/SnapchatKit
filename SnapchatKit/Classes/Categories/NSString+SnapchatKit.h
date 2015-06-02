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
+ (NSString *)sha256Hash:(NSData *)data;

/** Implementation of Snapchat's hashing algorithm. */
+ (NSString *)hashSC:(NSData *)first and:(NSData *)second;
+ (NSString *)hashSCString:(NSString *)first and:(NSString *)second;

+ (NSString *)hashHMac:(NSString *)data key:(NSString *)key;

@end

@interface NSString (REST)

+ (NSString *)timestamp;
+ (NSString *)queryStringWithParams:(NSDictionary *)params;

@end

@interface NSString (Regex)
- (NSString *)matchGroupAtIndex:(NSUInteger)idx forRegex:(NSString *)regex;
- (NSArray *)allMatchesForRegex:(NSString *)regex;
@end