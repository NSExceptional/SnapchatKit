//
//  NSString+Encoding.m
//  SnapchatKit
//
//  Created by Tanner on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSString+SnapchatKit.h"
#import "NSData+SnapchatKit.h"
#import "SnapchatKit-Constants.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (Encoding)

- (NSData *)base64DecodedData {
    return [[NSData alloc] initWithBase64EncodedString:self options:0];
}

- (NSString *)base64Encode {
    NSData *stringData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [stringData base64EncodedStringWithOptions:0];
}

- (NSString *)base64Decode {
    return [[NSString alloc] initWithData:self.base64DecodedData encoding:NSUTF8StringEncoding];
}

- (NSString *)sha256Hash {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha256Hash];
}

- (NSData *)sha256HashRaw {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (unsigned int)data.length, result);
    
    data = [[NSData alloc] initWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
    
    return data;
}

+ (NSString *)hashSCString:(NSString *)first and:(NSString *)second {
    return [NSString hashSC:[first dataUsingEncoding:NSUTF8StringEncoding] and:[second dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString *)hashSC:(NSData *)a and:(NSData *)b {
    NSData *secretData = [SKConsts.secret dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *firstData  = secretData.mutableCopy;
    NSMutableData *secondData = b.mutableCopy;
    
    // Append secret to values
    [firstData appendData:a];
    [secondData appendData:secretData];
    
    // SHA256 hash data
    NSString *first  = [firstData sha256Hash];
    NSString *second = [secondData sha256Hash];
    
    // SC hash
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < SKConsts.hashPattern.length; i++) {
        if ([SKConsts.hashPattern characterAtIndex:i] == '0')
            [hash appendFormat:@"%C", [first characterAtIndex:i]];
        else
            [hash appendFormat:@"%C", [second characterAtIndex:i]];
    }
    
    return hash;
}

+ (NSString *)hashHMacToString:(NSString *)data key:(NSString *)key {
    return [[self hashHMac:data key:key] base64EncodedStringWithOptions:0];
}

+ (NSData *)hashHMac:(NSString *)data key:(NSString *)key {
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}

- (NSString *)MD5Hash {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end


@implementation NSString (REST)

+ (NSString *)timestamp {
    return [self timestampFrom:[NSDate date]];
}

+ (NSString *)timestampFrom:(NSDate *)date {
    NSTimeInterval time = date.timeIntervalSince1970;
    return [NSString stringWithFormat:@"%llu", (unsigned long long)round(time *1000.0)];
}

+ (NSString *)queryStringWithParams:(NSDictionary *)params {
    return [NSString queryStringWithParams:params URLEscapeValues:NO];
}

+ (NSString *)queryStringWithParams:(NSDictionary *)params URLEscapeValues:(BOOL)escapeValues {
    if (params.allKeys.count == 0) return @"";
    
    NSMutableString *q = [NSMutableString string];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        if ([value isKindOfClass:[NSString class]]) {
            if (escapeValues) {
                value = [value URLEncodedString];
            } else {
                value = [value stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            }
        }
        [q appendFormat:@"%@=%@&", key, value];
    }];
    
    [q deleteCharactersInRange:NSMakeRange(q.length-1, 1)];
    
    return q;
}

- (NSString *)URLEncodedString {
    NSMutableString *encoded    = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)self.UTF8String;
    NSInteger sourceLen         = (NSInteger)strlen((const char *)source);
    
    for (NSInteger i = 0; i < sourceLen; i++) {
        const unsigned char c = source[i];
        if (c == ' '){
            [encoded appendString:@"+"];
        } else if (c == '.' || c == '-' || c == '_' || c == '~' ||
                   (c >= 'a' && c <= 'z') ||
                   (c >= 'A' && c <= 'Z') ||
                   (c >= '0' && c <= '9')) {
            [encoded appendFormat:@"%c", c];
        } else {
            [encoded appendFormat:@"%%%02X", c];
        }
    }
    
    return encoded;
}

@end


@implementation NSString (Regex)

- (NSString *)matchGroupAtIndex:(NSUInteger)idx forRegex:(NSString *)regex {
    NSArray *matches = [self matchesForRegex:regex];
    if (matches.count == 0) return nil;
    NSTextCheckingResult *match = matches[0];
    if (idx >= match.numberOfRanges) return nil;
    
    return [self substringWithRange:[match rangeAtIndex:idx]];
}

- (NSArray *)matchesForRegex:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
        return nil;
    NSArray *matches = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    if (matches.count == 0)
        return nil;
    
    return matches;
}

- (NSArray *)allMatchesForRegex:(NSString *)regex {
    NSArray *matches = [self matchesForRegex:regex];
    if (matches.count == 0) return @[];
    
    NSMutableArray *strings = [NSMutableArray new];
    for (NSTextCheckingResult *result in matches)
        [strings addObject:[self substringWithRange:[result rangeAtIndex:1]]];
    
    return strings;
}

- (NSString *)textFromHTML {
    if (!self.length)
        return @"";
    
    NSArray *strings = [self allMatchesForRegex:@"<title>(.*)<[^>]*>"];
    NSMutableString *text = [NSMutableString string];
    
    for (NSString *s in strings)
        if (s.length)
            [text appendFormat:@"%@—", s];
    [text deleteCharactersInRange:NSMakeRange(text.length-1, 1)];
    
    return text;
}

- (NSString *)stringByReplacingMatchesForRegex:(NSString *)pattern withString:(NSString *)replacement {
    return [self stringByReplacingOccurrencesOfString:pattern withString:replacement options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

@end


@implementation NSString (Snapchat)

+ (NSString *)SCIdentifierWith:(NSString *)first and:(NSString *)second {
    return [NSString stringWithFormat:@"%@~%@", first, second];
}

@end

NSString * SKMediaIdentifier(NSString *sender) {
    NSString *uuid = [NSUUID new].UUIDString.MD5Hash;
    return [NSString stringWithFormat:@"%@~%@", sender.uppercaseString, uuid];
}

NSString * SKUniqueIdentifier() {
    NSString *uuid = [NSUUID new].UUIDString.MD5Hash;
    return [NSString stringWithFormat:@"%8@-%4@-%4@-%4@-%12@",
            [uuid substringWithRange:NSMakeRange(0, 8)],
            [uuid substringWithRange:NSMakeRange(8, 4)],
            [uuid substringWithRange:NSMakeRange(12, 4)],
            [uuid substringWithRange:NSMakeRange(16, 4)],
            [uuid substringWithRange:NSMakeRange(20, 12)]];
}