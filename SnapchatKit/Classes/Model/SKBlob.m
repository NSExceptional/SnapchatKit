//
//  SKBlob.m
//  SnapchatKit
//
//  Created by Tanner on 6/13/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKBlob.h"
#import "SnapchatKit-Constants.h"
#import "NSData+SnapchatKit.h"

@implementation SKBlob

+ (instancetype)blobWithContentsOfPath:(NSString *)path {
    return [[self alloc] initWithContentsOfPath:path];
}

+ (instancetype)blobWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

- (id)initWithData:(NSData *)data {
    NSParameterAssert(data);
    
    self = [super init];
    if (self) {
        _data = data;
        _isImage = [_data isJPEG];
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
                        NSLog(@"Single file in zip: %@", files[0]);
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
                    NSLog(@"Single file in zip: %@", files);
                // Image
            } else if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                _data = [[NSData alloc] initWithContentsOfFile:path];
                if (!_data)
                    return nil;
            }
            
            // Delete file(s)
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            if (error && kVerboseLog)
                NSLog(@"Error deleting blob: %@", error);
        }
        
        _isImage = [self.data isJPEG];
    }
    
    return self;
}

- (void)writeToPath:(NSString *)path atomically:(BOOL)atomically {
    NSParameterAssert(path);
    if (!self.overlay)
        [self.data writeToFile:path atomically:atomically];
    else {
        NSString *dataName = self.isImage ? @"media.jpg" : @"media.mp4";
        [self.data writeToFile:[path stringByAppendingPathComponent:dataName] atomically:atomically];
        [self.overlay writeToFile:[path stringByAppendingPathComponent:@"overlay.jpg"] atomically:atomically];
    }
}

@end
