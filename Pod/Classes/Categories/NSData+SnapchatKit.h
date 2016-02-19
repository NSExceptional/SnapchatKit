//
//  NSData+SnapchatKit.h
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/5/15.
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

@property (nonatomic, readonly) BOOL isJPEG;
@property (nonatomic, readonly) BOOL isPNG;
@property (nonatomic, readonly) BOOL isImage;
@property (nonatomic, readonly) BOOL isMPEG4;
@property (nonatomic, readonly) BOOL isMedia;
@property (nonatomic, readonly) BOOL isCompressed;
@property (nonatomic, readonly) NSString *appropriateFileExtension;

@end

@interface NSData (Encoding)
@property (nonatomic, readonly) NSString *base64URLEncodedString;
@property (nonatomic, readonly) NSString *MD5Hash;
@property (nonatomic, readonly) NSString *hexadecimalString;
@property (nonatomic, readonly) NSString *sha256Hash;
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