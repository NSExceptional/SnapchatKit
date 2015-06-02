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
#include <zlib.h>

#import "SnapchatKit-Constants.h"

#define ChunkSize 16384

@implementation NSData (AES)

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key
{
    return [self AES128EncryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128DecryptedDataWithKey:(NSString *)key
{
    return [self AES128DecryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128Operation:kCCEncrypt key:key iv:iv];
}

- (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128Operation:kCCDecrypt key:key iv:iv];
}

// kCCModeCBC
- (NSData *)AES128Operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv
{
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
    
    NSUInteger count = (blockSize - data.length) % blockSize;
    
    for (NSUInteger i = 0; i < count; i++)
        [data appendBytes:0 length:1];
    
    return data.copy;
}

- (BOOL)isMedia {
    uint8_t a, b;
    [self getBytes:&a length:1];
    [self getBytes:&b range:NSMakeRange(1, 1)];
    
    // Check for a JPG header
    if(a == 0xFF && b == 0xD8)
        return YES;
    
    // Check for a MP4 header
    if(a == 0x00 && b == 0x00)
        return YES;
    
    return NO;
}

- (BOOL)isCompressed {
    uint8_t a, b, c, d;
    [self getBytes:&a length:1];
    [self getBytes:&b range:NSMakeRange(1, 1)];
    [self getBytes:&c range:NSMakeRange(2, 1)];
    [self getBytes:&d range:NSMakeRange(3, 1)];
    
    
    // Check for a PK header
    return a == 0x50 && b == 0x4B && c == 0x03 && d == 0x04;
}

@end


@implementation NSData (Blob)

/** Decrypts blob data for standard images and videos. */
+ (NSData *)decryptECB:(NSData *)data {
    return [[data pad:0] AES128DecryptedDataWithKey:kBlobEncryptionKey];
}

/** Encrypts blob data for standard images and videos. */
+ (NSData *)encryptECB:(NSData *)data {
    return [[data pad:0] AES128EncryptedDataWithKey:kBlobEncryptionKey];
}

+ (NSData *)decryptStory:(NSData *)data storyID:(NSInteger)storyID {
    NSString *key = [NSString stringWithFormat:@"/bq/story_blob?story_id=%ld", (long)storyID];
    return [self decryptCBC:data key:key iv:nil];
}

/** Decrypts blob data for stories. key and iv are base 64 encoded. */
+ (NSData *)decryptCBC:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    // Decode the key and IV
    iv = [iv base64Decode];
    key = [key base64Decode];
    NSMutableData *decrypted = [[data pad:0] AES128DecryptedDataWithKey:key iv:iv].mutableCopy;
    // $data = mcrypt_decrypt(MCRYPT_RIJNDAEL_128, $key, $data, MCRYPT_MODE_CBC, $iv);
    
    unsigned char buffer[1];
    [decrypted getBytes:buffer range:NSMakeRange(decrypted.length-1, 1)];
    NSUInteger padding = (NSUInteger)buffer;
    decrypted.length -= padding;
    
    return decrypted.copy;
}

@end

@implementation NSData (GZIP)

- (NSData *)gzippedDataWithCompressionLevel:(float)level
{
    if ([self length])
    {
        z_stream stream;
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        stream.opaque = Z_NULL;
        stream.avail_in = (uint)[self length];
        stream.next_in = (Bytef *)[self bytes];
        stream.total_out = 0;
        stream.avail_out = 0;
        
        int compression = (level < 0.0f)? Z_DEFAULT_COMPRESSION: (int)(roundf(level * 9));
        if (deflateInit2(&stream, compression, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK)
        {
            NSMutableData *data = [NSMutableData dataWithLength:ChunkSize];
            while (stream.avail_out == 0)
            {
                if (stream.total_out >= [data length])
                {
                    data.length += ChunkSize;
                }
                stream.next_out = (uint8_t *)[data mutableBytes] + stream.total_out;
                stream.avail_out = (uInt)([data length] - stream.total_out);
                deflate(&stream, Z_FINISH);
            }
            deflateEnd(&stream);
            data.length = stream.total_out;
            return data;
        }
    }
    return nil;
}

- (NSData *)gzippedData
{
    return [self gzippedDataWithCompressionLevel:-1.0f];
}

- (NSData *)gunzippedData
{
    NSUInteger full_length = [self length];
    NSUInteger half_length = full_length / 2;
    
    NSMutableData *inflatedData = [NSMutableData dataWithLength:full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    
    strm.next_in = (Bytef *)[self bytes];
    strm.avail_in = (unsigned int)[self length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, -MAX_WBITS) != Z_OK) return nil;
    while (!done) {
        if (strm.total_out >= [inflatedData length])
            [inflatedData increaseLengthBy:half_length];
        strm.next_out = [inflatedData mutableBytes] + strm.total_out;
        strm.avail_out = (unsigned int)([inflatedData length] - strm.total_out);
        status = inflate(&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END)
            done = YES;
        else if (status != Z_OK)
            break;
    }
    if (inflateEnd(&strm) == Z_OK && done)
        [inflatedData setLength:strm.total_out];
    else
        inflatedData = nil;
    return inflatedData;
}

@end