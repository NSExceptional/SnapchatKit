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

@end


@interface NSData (FileFormat)

- (BOOL)isJPEG;
- (BOOL)isPNG;
- (BOOL)isImage;
- (BOOL)isMPEG4;
- (BOOL)isMedia;
- (BOOL)isCompressed;
- (NSString *)appropriateFileExtension;

@end


@interface NSData (Encoding)
- (NSString *)MD5Hash;
- (NSString *)hexadecimalString;
- (NSString *)sha256Hash;
@end


@interface NSData (REST)
+ (NSData *)boundaryWithKey:(NSString *)key forStringValue:(NSString *)string;
+ (NSData *)boundaryWithKey:(NSString *)key forDataValue:(NSData *)data;
@end


@interface NSData (Blob)

/** Decrypts blob data for standard images and videos. */
//- (NSData *)decryptECB;
/** Encrypts blob data for standard images and videos. */
//- (NSData *)encryptECB;
/** Decrypts blob data for stories. key and iv are base 64 encoded. */
- (NSData *)decryptStoryWithKey:(NSString *)key iv:(NSString *)iv;

@end