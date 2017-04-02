//
//  SKAvatar.m
//  Pods
//
//  Created by Tanner on 1/2/16.
//
//

#import "SKAvatar.h"
#import <zlib.h>

#if USE_UIKIT
@import UIKit;
#else
@import AppKit;
#endif


@implementation SKAvatar

+ (instancetype)avatarWithData:(NSData *)data error:(NSError **)error {
    SKAvatar *avatar = [SKAvatar new];
    avatar->_username = [self usernameFromData:&data];
    NSArray *datas = [self imageDataFromAvatarData:data error:error];
    
    // Return nil if error
    if (!datas.count)
        return nil;
    
#if USE_UIKIT
    NSMutableArray *images = [NSMutableArray array];
    for (NSData *data in datas)
        [images addObject:[UIImage imageWithData:data]];
    avatar->_image = [UIImage animatedImageWithImages:images duration:1];
#else
    avatar->_frames = datas.copy;
#endif
    
    avatar->_lastUpdated = [self lastUpdatedFromAvatarData:data];
    avatar->_data = data;
    
    return avatar;
}

#if !USE_UIKIT
- (void)setImage:(NSImage *)image freeFrames:(BOOL)freeFrames {
    NSParameterAssert(image);
    
    _image = image;
    if (freeFrames)
        _frames = nil;
}
#endif

#pragma mark - Internal

+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code {
    return [NSError errorWithDomain:@"SnapchatKit" code:code userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(message, @""),
                                                                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(message, @"")}];
}

+ (NSDate *)lastUpdatedFromAvatarData:(NSData *)data {
    unsigned long lastUpdated = 0;
    [data getBytes:&lastUpdated range:NSMakeRange(1, 8)];
    lastUpdated = NSSwapLong(lastUpdated); // Big endian
    
    return [NSDate dateWithTimeIntervalSince1970:lastUpdated/1000];
}

+ (NSArray<NSData*> *)imageDataFromAvatarData:(NSData *)data error:(NSError **)error {
    NSParameterAssert(data);
    
    // Get # images, must be 5
    NSInteger count = 0;
    [data getBytes:&count length:1];
    if (count != 5) {
        // Scan for leading username, will be terminated by \0\0
//        char c = '\0';
//        NSInteger len = 0;
//        do {
//            [data getBytes:&c range:NSMakeRange(len++, 1)];
//        } while (isalnum(c));
//        
//        // Try again after finding the username
//        if (len > 1 && c == '\0') {
//            len += 1; // Here len is 1 more than the username but we need it 2 more than the username
//            data = [data subdataWithRange:NSMakeRange(len, data.length - len)];
//            return [self imageDataFromAvatarData:data error:error];
//        } else {
            NSString *message = [NSString stringWithFormat:@"Count of %@ images does not match expected count of 5", @(count)];
            if (error) *error = [self errorWithMessage:message code:1];
            return nil;
//        }
    }
    
    // Get data
    NSMutableArray *datas = [NSMutableArray array];
    NSInteger offset = 9;
    for (NSInteger i = 0; i < 5; i++) {
        unsigned int size = 0; unsigned long hash = 0;
        
        // Read size
        [data getBytes:&size range:NSMakeRange(offset, 4)];
        size = NSSwapInt(size); // Big endian
        offset += 4;
        
        // Read image
        [datas addObject:[data subdataWithRange:NSMakeRange(offset, size)]];
        offset += size;
        
        // Read hash, might use later
        [data getBytes:&hash range:NSMakeRange(offset, 8)];
        offset += 8;
    }
    
    return datas;
}

+ (NSData *)avatarDataFromImageDatas:(NSArray<NSData*> *)imageDatas {
    NSParameterAssert(imageDatas.count == 5);
    
    NSMutableData *data = [NSMutableData dataWithCapacity:1 + 8 + 5 * (4 + 8)];
    
    // Write count
    short count = 5;
    [data appendBytes:&count length:1];
    
    // Write last updated ts
    unsigned long updatedts = [[NSDate date] timeIntervalSince1970] * 1000;
    updatedts = NSSwapLong(updatedts);
    [data appendBytes:&updatedts length:8];
    
    // Write sizes, images, hashes
    for (NSData *image in imageDatas) {
        unsigned int size = NSSwapInt( (unsigned int)image.length );
        unsigned long hash = NSSwapLong( crc32(0, image.bytes, (unsigned int)image.length) );
        
        [data appendBytes:&size length:4];
        [data appendData:image];
        [data appendBytes:&hash length:8];
    }
    
    return data;
}

+ (NSString *)usernameFromData:(NSData **)data {
    char c = '\0';
    NSInteger len = 0;
    do {
        [*data getBytes:&c range:NSMakeRange(len++, 1)];
    } while (isalnum(c));
    
    
    // Did we find a username?
    if (len > 1 && c == '\0') {
        len--;
        NSString *username = [[NSString alloc] initWithData:[*data subdataWithRange:NSMakeRange(0, len)] encoding:NSUTF8StringEncoding];
        len += 2; // we need it 2 more than the username to pass the \0\0 terminator
        *data = [*data subdataWithRange:NSMakeRange(len, [(*data) length] - len)];
        return username;
    }
    
    return nil;
}

@end






























