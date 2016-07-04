//
//  NSData+SnapchatKit.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSData+SnapchatKit.h"


@implementation NSData (SnapchatKit)

/** Decrypts blob data for standard images and videos. */
//- (NSData *)decryptECB {
//    return [[self pad:0] AES128DecryptedDataWithKey:kBlobEncryptionKey];
//}

/** Encrypts blob data for standard images and videos. */
//- (NSData *)encryptECB {
//    return [[self pad:0] AES128EncryptedDataWithKey:kBlobEncryptionKey];
//}

/** Decrypts blob data for stories. key and iv are base 64 encoded. */
- (NSData *)decryptStoryWithKey:(NSString *)key iv:(NSString *)iv {
    // Decode the key and IV
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:key options:0];
    NSData *ivData  = [[NSData alloc] initWithBase64EncodedString:iv options:0];
    
    return [self AES128DecryptedDataWithKeyData:keyData ivData:ivData];
}

@end