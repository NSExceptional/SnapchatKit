//
//  NSDictionary+SnapchatKit.m
//  SnapchatKit
//
//  Created by Tanner on 5/22/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSDictionary+SnapchatKit.h"

@implementation NSDictionary (JSON)

- (NSString *)JSONString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"{}";
}

@end


@implementation NSDictionary (Util)

- (NSArray *)split:(NSUInteger)entryLimit {
    NSParameterAssert(entryLimit > 0);
    if (self.allKeys.count <= entryLimit)
        return @[self];
    
    NSMutableArray *dicts = [NSMutableArray array];
    __block NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        tmp[key] = obj;
        if (tmp.allKeys.count % entryLimit == 0) {
            [dicts addObject:tmp];
            tmp = [NSMutableDictionary dictionary];
        }
    }];
    
    return dicts;
}

- (NSDictionary *)dictionaryByReplacingValuesForKeys:(NSDictionary *)dictionary {
    if (!dictionary || !dictionary.allKeys.count || !self) return self;
    
    NSMutableDictionary *m = self.mutableCopy;
    for (NSString *key in dictionary.allKeys)
        m[key] = dictionary[key];
    
    return m;
}

- (NSDictionary *)dictionaryByReplacingKeysWithNewKeys:(NSDictionary *)oldKeysToNewKeys {
    if (!oldKeysToNewKeys || !oldKeysToNewKeys.allKeys.count || !self) return self;
    
    NSMutableDictionary *m = self.mutableCopy;
    [oldKeysToNewKeys enumerateKeysAndObjectsUsingBlock:^(NSString *oldKey, NSString *newKey, BOOL *stop) {
        id val = m[oldKey];
        m[oldKey] = nil;
        m[newKey] = val;
    }];
    
    return m;
}

@end