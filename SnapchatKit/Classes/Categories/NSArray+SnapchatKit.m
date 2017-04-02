//
//  NSArray+SnapchatKit.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/22/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSArray+SnapchatKit.h"
#import "Mantle.h"


@implementation NSArray (SnapchatKit)

- (NSArray *)dictionaryValues {
    NSMutableArray *jsons = [NSMutableArray array];
    for (id<MTLJSONSerializing>foo in self)
        [jsons addObject:[MTLJSONAdapter JSONDictionaryFromModel:foo error:nil]];
    
    return jsons.copy;
}

- (NSString *)recipientsString {
    if (!self.count) return @"[]";
    
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"["];
    
    for (NSString *recipient in self)
        [string appendFormat:@"\"%@\",", recipient];
    
    [string deleteCharactersInRange:NSMakeRange(string.length-1, 1)];
    [string appendString:@"]"];
    
    return string;
}

@end