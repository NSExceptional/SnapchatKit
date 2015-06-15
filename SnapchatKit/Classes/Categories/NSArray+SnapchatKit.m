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
