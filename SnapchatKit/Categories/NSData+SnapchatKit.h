//
//  NSData+SnapchatKit.h
//  SnapchatKit
//
//  Created by Tanner on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key;
- (NSData *)AES128DecryptedDataWithKey:(NSString *)key;
- (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv;
- (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv;

/** Pads data using PKCS5. blockSize defaults to 16 if given 0. */
- (NSData *)pad:(NSUInteger)blockSize;

/** Checks to see if a blob looks like a media file. */
- (BOOL)isMedia;
/** Checks to see if a blob looks like a compressed file. */
- (BOOL)isCompressed;

@end


@interface NSData (Blob)

/** Decrypts blob data for standard images and videos. */
+ (NSData *)decryptECB:(NSData *)data;

/** Encrypts blob data for standard images and videos. */
+ (NSData *)encryptECB:(NSData *)data;

+ (NSData *)decryptStory:(NSData *)data storyID:(NSInteger)storyID;

/** Decrypts blob data for stories. key and iv are base 64 encoded. */
+ (NSData *)decryptCBC:(NSData *)data key:(NSString *)key iv:(NSString *)iv;
@end