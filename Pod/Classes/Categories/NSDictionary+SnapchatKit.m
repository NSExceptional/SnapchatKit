//
//  NSDictionary+SnapchatKit.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/22/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSDictionary+SnapchatKit.h"
#import "NSString+SnapchatKit.h"
#import "NSData+SnapchatKit.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonHMAC.h>


@implementation NSDictionary (JSON)

- (NSString *)JSONString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"{}";
}

- (NSString *)JWTStringWithSecret:(NSString *)key {
    NSString *header = @"{\"typ\":\"JWT\",\"alg\":\"HS256\"}";
    NSString *payload = [self.JSONString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    
    NSString *data = [@"." join:@[header.base64URLEncoded, payload.base64URLEncoded]];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, key.UTF8String, strlen(key.UTF8String), data.UTF8String, strlen(data.UTF8String), cHMAC);
    NSData *signature = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    return [@"." join:@[data, signature.base64URLEncodedString]];
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
    [m setValuesForKeysWithDictionary:dictionary];
    return m.copy;
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

- (NSArray *)allKeyPaths {
    NSMutableArray *keyPaths = [NSMutableArray array];
    
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [keyPaths addObject:key];
       
        if ([obj isKindOfClass:[NSDictionary class]]) {
            for (NSString *kp in [obj allKeyPaths])
                [keyPaths addObject:[NSString stringWithFormat:@"%@.%@", key, kp]];
        }
    }];
    
    return keyPaths.copy;
}

@end