//
//  NSString+Encoding.m
//  SnapchatKit
//
//  Created by Tanner on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSString+SnapchatKit.h"
#import "SnapchatKit-Constants.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (Encoding)

- (NSString *)base64Encode {
    NSData *stringData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [stringData base64EncodedStringWithOptions:0];
}

- (NSString *)base64Decode {
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self options:0];
    return [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
}

+ (NSString *)sha256Hash:(NSData *)data {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (unsigned int)data.length, result);
    
    NSMutableString *hash = [NSMutableString string];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02x", result[i]];
    
    return hash;
}

+ (NSString *)hashSCString:(NSString *)first and:(NSString *)second {
    return [NSString hashSC:[first dataUsingEncoding:NSUTF8StringEncoding] and:[second dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString *)hashSC:(NSData *)a and:(NSData *)b {
    NSData *secretData = [kSecret dataUsingEncoding:NSASCIIStringEncoding];
    
    NSMutableData *firstData  = secretData.mutableCopy;
    NSMutableData *secondData = b.mutableCopy;
    
    // Append secret to values
    [firstData appendData:a];
    [secondData appendData:secretData];
    
    // SHA256 hash data
    NSString *first  = [NSString sha256Hash:firstData];
    NSString *second = [NSString sha256Hash:secondData];
    
    // SC hash
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < kHashPattern.length; i++) {
        if ([kHashPattern characterAtIndex:i] == '0')
            [hash appendFormat:@"%C", [first characterAtIndex:i]];
        else
            [hash appendFormat:@"%C", [second characterAtIndex:i]];
    }
    
    return hash;
}

+ (NSString *)hashHMac:(NSString *)data key:(NSString *)key {
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    return [HMAC base64EncodedStringWithOptions:0];
}

@end

@implementation NSString (REST)

+ (NSString *)timestamp {
    NSTimeInterval time = [NSDate date].timeIntervalSince1970;
    return [NSString stringWithFormat:@"%llu", (unsigned long long)round(time *1000.0)];
}

+ (NSString *)queryStringWithParams:(NSDictionary *)params {
    if (params.allKeys.count == 0) return @"";
    
    NSMutableString *q = [NSMutableString string];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        if ([value isKindOfClass:[NSString class]])
            value = [(NSString *)value stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        [q appendFormat:@"%@=%@&", key, value];
    }];
    
    [q deleteCharactersInRange:NSMakeRange(q.length-1, 1)];
    
    return q;
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
        [strings addObject:[self substringWithRange:result.range]];
    
    return strings;
}

@end