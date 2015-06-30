//
//  NSArray+SnapchatKit.m
//  SnapchatKit
//
//  Created by Tanner on 5/22/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSArray+SnapchatKit.h"

@implementation NSArray (JSON)

- (NSString *)JSONString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"[]";
}

@end

@implementation NSArray (REST)

- (NSString *)formatRecipients {
    
    NSMutableString *formattedRecipients = [@"[" mutableCopy];
    for (int i = 0; i < self.count; i++) {
        if (i != (self.count - 1)) {
            [formattedRecipients appendFormat:@"\"%@\",", self[i]];
        } else {
            [formattedRecipients appendFormat:@"\"%@\"", self[i]];
        }
    }
    [formattedRecipients appendString:@"]"];
    
    return formattedRecipients;
}

@end