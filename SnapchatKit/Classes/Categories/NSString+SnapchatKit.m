//
//  NSString+SnapchatKit.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SnapchatKit-Constants.h"


@implementation NSString (SnapchatKit)

+ (NSString *)hashSC:(NSData *)a and:(NSData *)b {
    NSData *secretData = [SKConsts.secret dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *firstData  = secretData.mutableCopy;
    NSMutableData *secondData = b.mutableCopy;
    
    // Append secret to values
    [firstData appendData:a];
    [secondData appendData:secretData];
    
    // SHA256 hash data
    NSString *first  = firstData.sha256Hash;
    NSString *second = secondData.sha256Hash;
    
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

+ (NSString *)hashSCString:(NSString *)first and:(NSString *)second {
    return [NSString hashSC:[first dataUsingEncoding:NSUTF8StringEncoding] and:[second dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString *)timestampInSeconds {
    return [NSString stringWithFormat:@"%llu", (unsigned long long)[NSDate date].timeIntervalSince1970];
}

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