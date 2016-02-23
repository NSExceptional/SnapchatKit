//
//  SKBlob.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 6/13/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKBlob.h"
#import "SnapchatKit-Constants.h"
#import "NSData+SnapchatKit.h"
#import "NSString+SnapchatKit.h"
#import "SKStory.h"
#import "SKRequest.h"

#import "SSZipArchive.h"
@import AVFoundation;

@implementation SKBlob
@synthesize zipData = _zipData;

+ (instancetype)blobWithContentsOfPath:(NSString *)path {
    return [[self alloc] initWithContentsOfPath:path];
}

+ (instancetype)blobWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

+ (void)blobWithStoryData:(NSData *)blobData forStory:(SKStory *)story isThumb:(BOOL)thumb completion:(ResponseBlock)completion {
    NSParameterAssert(blobData); NSParameterAssert(story); NSParameterAssert(completion);
    [self decryptBlob:blobData forStory:story isThumb:thumb completion:completion];
}

+ (void)decompressBlob:(NSData *)blobData forStory:(SKStory *)story completion:(ResponseBlock)completion {
    NSParameterAssert(blobData); NSParameterAssert(story); NSParameterAssert(completion);
    NSString *path  = [SKTempDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"sk-zip~%@.tmp", story.identifier]];
    NSString *unzip = [SKTempDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"sk~%@.tmp", story.identifier]];
    [blobData writeToFile:path atomically:YES];
    
    [SSZipArchive unzipFileAtPath:path toDestination:unzip completion:^(NSString *path, BOOL succeeded, NSError *error) {
        if (succeeded) {
            completion([SKBlob blobWithContentsOfPath:unzip], nil);
        } else {
            completion(nil, error);
        }
        
        NSError *e = nil;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&e];
        if (e && kVerboseLog) SKLog(@"Error deleting blob: %@", e); e = nil;
        [[NSFileManager defaultManager] removeItemAtPath:unzip error:&e];
        if (e && kVerboseLog) SKLog(@"Error deleting blob: %@", e); e = nil;
    }];
}

+ (void)decryptBlob:(NSData *)blobData forStory:(SKStory *)story isThumb:(BOOL)thumb completion:(ResponseBlock)completion {
    NSParameterAssert(blobData); NSParameterAssert(story); NSParameterAssert(completion);
    if ((!blobData.isCompressed && !blobData.isMedia)) {
        if (thumb)
            blobData = [blobData decryptStoryWithKey:story.mediaKey iv:story.thumbIV];
        else
            blobData = [blobData decryptStoryWithKey:story.mediaKey iv:story.mediaIV];
    }
    
    if (blobData.isCompressed) {
        [self decompressBlob:blobData forStory:story completion:completion];
    } else {
        SKBlob *blob = [SKBlob blobWithData:blobData];
        if (blob)
            completion(blob, blobData.isMedia ? nil : [SKRequest errorWithMessage:@"Unknown blob format" code:1]);
        else
            completion(nil, [SKRequest errorWithMessage:@"Error initializing blob with data" code:1]);
    }
}

- (id)initWithData:(NSData *)data {
    NSParameterAssert(data.length);
    
    self = [super init];
    if (self) {
        _data = data;
        _isImage = _data.isJPEG || _data.isPNG;
        _isVideo = _data.isMPEG4;
        
    }
    
    return self;
}

- (id)initWithContentsOfPath:(NSString *)path {
    NSParameterAssert(path);
    
    self = [super init];
    if (self) {
        BOOL isFolder = NO;
        BOOL exists   = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isFolder];
        
        if (exists) {
            // Video
            if (isFolder) {
                NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
                if (!files.count)
                    return nil;
                
                // Single file?
                if (files.count == 1) {
                    _data = [[NSData alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:files[0]]];
                    if (kVerboseLog)
                        SKLog(@"Single file in zip: %@", files[0]);
                }
                
                // Load video blob and image blob
                else if ([files[0] containsString:@"media~"]) {
                    _data = [[NSData alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:files[0]]];
                    _overlay = [[NSData alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:files[1]]];
                } else if ([files[1] containsString:@"media~"]) {
                    _data = [[NSData alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:files[1]]];
                    _overlay = [[NSData alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:files[0]]];
                }
                
                // Errors
                if (!_data)
                    return nil;
                if (!_overlay && kVerboseLog)
                    SKLog(@"Single file in zip: %@", files);
                // Image
            } else {
                _data = [[NSData alloc] initWithContentsOfFile:path];
                if (!_data)
                    return nil;
            }
            
            // Delete file(s)
            //            NSError *error = nil;
            //            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            //            if (error && kVerboseLog)
            //                SKLog(@"Error deleting blob: %@", error);
        } else {
            return nil;
        }
        
        _isImage = _data.isJPEG || _data.isPNG;
        _isVideo = _data.isMPEG4;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKBlob class]])
        return [self isEqualToBlob:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToBlob:(SKBlob *)blob {
    return [self.data isEqualToData:blob.data];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ isImage=%d, has overlay=%d, bytes=%lu>",
            NSStringFromClass(self.class), self.isImage, (BOOL)self.overlay, (unsigned long)self.data.length];
}

- (NSArray *)writeToPath:(NSString *)path filename:(NSString *)filename atomically:(BOOL)atomically {
    NSParameterAssert(path);
    
    if (!self.overlay) {
        path = [path stringByAppendingPathComponent:[filename stringByAppendingString:self.data.appropriateFileExtension]];
        [self.data writeToFile:path atomically:atomically];
        return @[path];
    } else {
        path = [path stringByAppendingPathComponent:filename];
        NSString *overlay    = [path stringByAppendingPathComponent:[filename stringByAppendingString:[@"-overlay" stringByAppendingString:_overlay.appropriateFileExtension]]];
        NSString *video      = [path stringByAppendingPathComponent:[filename stringByAppendingString:_data.appropriateFileExtension]];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        [self.data writeToFile:video atomically:atomically];
        [self.overlay writeToFile:overlay atomically:atomically];
        return @[video, overlay];
    }
}

- (void)decompress:(ResponseBlock)completion {
    if (self.data.isCompressed) {
        NSString *uuid  = [NSUUID UUID].UUIDString;
        NSString *path  = [SKTempDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"sk-zip~%@.tmp", uuid]];
        NSString *unzip = [SKTempDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"sk~%@.tmp", uuid]];
        [self.data writeToFile:path atomically:YES];
        
        [SSZipArchive unzipFileAtPath:path toDestination:unzip completion:^(NSString *path, BOOL succeeded, NSError *error) {
            if (succeeded) {
                SKBlob *blob = [SKBlob blobWithContentsOfPath:unzip];
                if (blob) {
                    completion(blob, nil);
                } else {
                    completion(nil, [SKRequest errorWithMessage:@"Error initializing blob" code:2]);
                }
            } else {
                SKLog(@"%@", error);
            }
        }];
    } else {
        completion(self, nil);
    }
}

- (NSData *)zipData {
    if (_zipData) return _zipData;
    
    if (self.overlay) {
        NSString *tmpDir      = SKUniqueIdentifier();
        NSString *videoName   = [@"media~zip-" stringByAppendingString:SKUniqueIdentifier().capitalizedString];
        NSString *overlayName = [@"overlay~zip-" stringByAppendingString:SKUniqueIdentifier().capitalizedString];
        NSString *folder      = [SKTempDirectory() stringByAppendingPathComponent:tmpDir];
        NSString *archive     = [SKTempDirectory() stringByAppendingPathComponent:[tmpDir stringByAppendingString:@".zip"]];
        NSString *video       = [folder stringByAppendingPathComponent:videoName];
        NSString *overlay     = [folder stringByAppendingPathComponent:overlayName];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
        [self.data writeToFile:video atomically:YES];
        [self.overlay writeToFile:overlay atomically:YES];
        BOOL success = [SSZipArchive createZipFileAtPath:archive withContentsOfDirectory:folder];
        
        if (success) {
            _zipData = [NSData dataWithContentsOfFile:archive];
            // zip failed
            if (_zipData.length == 22) _zipData = nil;
        }
        
        // Cleanup
        [[NSFileManager defaultManager] removeItemAtPath:archive error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:folder error:nil];
    }
    
    return _zipData;
}

- (NSData *)videoThumbnail {
    if (_videoThumbnail) return _videoThumbnail;
    
    if (self.isVideo) {
        NSString *path = [SKTempDirectory() stringByAppendingPathComponent:@"tmp-video.mp4"];
        [self.data writeToFile:path atomically:YES];
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
        
        AVAssetImageGenerator *gen = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        
        CGImageRef image = [gen copyCGImageAtTime:CMTimeMake(0, 600) actualTime:NULL error:NULL];
        if (image != NULL) {
            _videoThumbnail = SKThumbnailFromGCImage(image);
            CGImageRelease(image);
        }
        
        // Cleanup
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    return _videoThumbnail;
}

@end



NSData * SKThumbnailFromGCImage(CGImageRef image) {
    CGFloat width  = CGImageGetWidth(image);
    CGFloat height = CGImageGetHeight(image);
    CGFloat s  = MIN(MIN(width, height), 102);
    
    // Images too small to scale
    if (s < 102) {
        CGFloat cx = s/2.f - 51;
        CGFloat cy = s/2.f - 51;
        CGImageRef cropped = CGImageCreateWithImageInRect(image, CGRectMake(cx, cy, s, s));
        return CFBridgingRelease(CGDataProviderCopyData(CGImageGetDataProvider(cropped)));
    }
    
    CGFloat scale              = MIN(width, height) / 102.f;
    NSInteger bitsPerComponent = CGImageGetBitsPerComponent(image);
    NSInteger bytesPerRow      = CGImageGetBytesPerRow(image);
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    CGBitmapInfo bitmapInfo    = CGImageGetBitmapInfo(image);
    width /= scale; height /= scale;
    CGFloat cx = (width - s) / 2.f;
    CGFloat cy = (height - s) / 2.f;
    
    CGContextRef context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGImageRef scaled = CGBitmapContextCreateImage(context);
    CGImageRef cropped = CGImageCreateWithImageInRect(scaled, CGRectMake(cx, cy, s, s));
    
    // Cleanup
    CGImageRelease(scaled);
    NSData *ret;
#if __has_include(<UIKit/UIImage.h>)
    ret = UIImagePNGRepresentation([UIImage imageWithCGImage:cropped]);
#elif __has_include(<AppKit/NSImage.h>)
    ret = [[[NSBitmapImageRep alloc] initWithCGImage:cropped] representationUsingType:NSPNGFileType properties:@{}];
#else
#warning Target platform is missing a way to convert a CGImage to NSData.
#endif
    CGImageRelease(cropped);
    
    return ret;
}











