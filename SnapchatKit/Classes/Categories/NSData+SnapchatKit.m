//
//  NSData+SnapchatKit.m
//  SnapchatKit
//
//  Created by Tanner on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSData+SnapchatKit.h"
#import "NSString+SnapchatKit.h"
#import <CommonCrypto/CommonCryptor.h>

#import "SnapchatKit-Constants.h"

#define ChunkSize 16384

@implementation NSData (AES)

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key {
    return [self AES128EncryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128DecryptedDataWithKey:(NSString *)key {
    return [self AES128DecryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv {
    return [self AES128Operation:kCCEncrypt key:key iv:iv];
}

- (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv {
    return [[self pad:0] AES128Operation:kCCDecrypt key:key iv:iv];
}

// kCCModeCBC
- (NSData *)AES128Operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv {
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    if (iv) {
        [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    }

    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);

    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

- (NSData *)pad:(NSUInteger)blockSize {
    NSMutableData *data = self.mutableCopy;
    if (blockSize == 0)
        blockSize = 16;
    
    NSUInteger count = blockSize - (data.length % blockSize);
    data.length = data.length + count;
    
    return data;
}

- (BOOL)isJPEG {
    uint8_t a, b, c, d;
    [self getHeader:&a b:&b c:&c d:&d];
    
    return a == 0xFF && b == 0xD8 && c == 0xFF && d == 0xE0;
}

- (BOOL)isMPEG4 {
    uint8_t a, b, c, d;
    [self getHeader:&a b:&b c:&c d:&d];
    
    return a == 0xFF && b == 0xD8 && c == 0xFF && d == 0xE0;
}

- (BOOL)isCompressed {
    uint8_t a, b, c, d;
    [self getHeader:&a b:&b c:&c d:&d];
    
    // PK header
    return a == 0x50 && b == 0x4B && c == 0x03 && d == 0x04;
}

- (void)getHeader:(void *)a b:(void *)b c:(void *)c d:(void *)d {
    [self getBytes:a length:1];
    [self getBytes:b range:NSMakeRange(1, 1)];
    [self getBytes:c range:NSMakeRange(2, 1)];
    [self getBytes:d range:NSMakeRange(3, 1)];
}

@end


@implementation NSData (Blob)

/** Decrypts blob data for standard images and videos. */
- (NSData *)decryptECB {
    return [[self pad:0] AES128DecryptedDataWithKey:kBlobEncryptionKey];
}

/** Encrypts blob data for standard images and videos. */
- (NSData *)encryptECB {
    return [[self pad:0] AES128EncryptedDataWithKey:kBlobEncryptionKey];
}

// This probably doesn't work at all. Idr where I got this code from.
- (NSData *)decryptStoryWithIdentifier:(NSInteger)storyID {
    NSString *key = [NSString stringWithFormat:@"/bq/story_blob?story_id=%ld", (long)storyID];
    return [self decryptCBCWithKey:key iv:nil];
}

/** Decrypts blob data for stories. key and iv are base 64 encoded. */
- (NSData *)decryptCBCWithKey:(NSString *)key iv:(NSString *)iv {
    // Decode the key and IV
    iv = [iv base64Decode];
    key = [key base64Decode];
    NSMutableData *decrypted = [[self pad:0] AES128DecryptedDataWithKey:key iv:iv].mutableCopy;
    
    unsigned char buffer[1];
    [decrypted getBytes:buffer range:NSMakeRange(decrypted.length-1, 1)];
    NSUInteger padding = (NSUInteger)buffer;
    decrypted.length -= padding;
    
    return decrypted;
}

@end