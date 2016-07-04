//
//  NSData+SnapchatKit.h
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSData+Networking.h"


@interface NSData (SnapchatKit)

/** Decrypts blob data for standard images and videos. */
//- (NSData *)decryptECB;
/** Encrypts blob data for standard images and videos. */
//- (NSData *)encryptECB;
/** Decrypts blob data for stories. key and iv are base 64 encoded. */
- (NSData *)decryptStoryWithKey:(NSString *)key iv:(NSString *)iv;

@end