//
//  SKBlob.m
//  SnapchatKit
//
//  Created by Tanner on 6/13/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SKBlob.h"
#import "SnapchatKit-Constants.h"
#import "NSData+SnapchatKit.h"
#import "SKStory.h"

#import "SKRequest.h"

#import "SSZipArchive.h"

@implementation SKBlob

+ (instancetype)blobWithContentsOfPath:(NSString *)path {
    return [[self alloc] initWithContentsOfPath:path];
}

+ (instancetype)blobWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

+ (void)blobWithStoryData:(NSData *)encryptedBlob forStory:(SKStory *)story completion:(ResponseBlock)completion {
    NSParameterAssert(encryptedBlob);
    NSData *decryptedBlob = [encryptedBlob decryptStoryWithKey:story.mediaKey iv:story.mediaIV];
    
    // Unzipped
    if ([decryptedBlob isJPEG] || [decryptedBlob isMPEG4]) {
        SKBlob *blob = [SKBlob blobWithData:decryptedBlob];
        if (blob)
            completion(blob, nil);
        else
            completion(nil, [SKRequest errorWithMessage:@"Error initializing blob with data" code:1]);
        
        // Needs to be unzipped
    } else if ([decryptedBlob isCompressed]) {
        NSString *path  = [SKTempDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"sk-zip~%@.tmp", story.identifier]];
        NSString *unzip = [SKTempDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"sk~%@.tmp", story.identifier]];
        [decryptedBlob writeToFile:path atomically:YES];
        
        [SSZipArchive unzipFileAtPath:path toDestination:unzip completion:^(NSString *path, BOOL succeeded, NSError *error) {
            if (succeeded) {
                SKBlob *blob = [SKBlob blobWithContentsOfPath:unzip];
                if (blob)
                    completion(blob, nil);
                else
                    completion(nil, [SKRequest errorWithMessage:@"Error initializing blob" code:2]);
            } else {
                SKLog(@"%@", error);
            }
        }];
    } else if (decryptedBlob) {
        SKBlob *blob = [SKBlob blobWithData:decryptedBlob];
        if (blob)
            completion(blob, [SKRequest errorWithMessage:@"Unknown blob format" code:1]);
        else
            completion(nil, [SKRequest errorWithMessage:@"Error initializing blob with data" code:1]);
    } else {
        completion(nil, [SKRequest errorWithMessage:[NSString stringWithFormat:@"Error retrieving story: %@", story.identifier] code:2]);
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
                else if ([files[0] containsString:@"media~zip"]) {
                    _data = [[NSData alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:files[0]]];
                    _overlay = [[NSData alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:files[1]]];
                } else if ([files[1] containsString:@"media~zip"]) {
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
    return [NSString stringWithFormat:@"<%@ isImage=%hhd, has overlay=%hhd, bytes=%lu>",
            NSStringFromClass(self.class), self.isImage, (BOOL)self.overlay, (unsigned long)self.data.length];
}

- (void)writeToPath:(NSString *)path atomically:(BOOL)atomically {
    NSParameterAssert(path);
    
    if (!self.overlay)
        [self.data writeToFile:path atomically:atomically];
    else {
        if (![[NSFileManager defaultManager] fileExistsAtPath:path])
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *dataName = self.isImage ? @"media.jpg" : @"media.mp4";
        [self.data writeToFile:[path stringByAppendingPathComponent:dataName] atomically:atomically];
        [self.overlay writeToFile:[path stringByAppendingPathComponent:@"overlay.jpg"] atomically:atomically];
    }
}

@end
