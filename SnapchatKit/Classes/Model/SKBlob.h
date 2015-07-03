//
//  SKBlob.h
//  SnapchatKit
//
//  Created by Tanner on 6/13/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapchatKit-Constants.h"

@class SKStory;

@interface SKBlob : NSObject

/**
 path can be a path to a folder (containing a video and overlay) or a single snap.
 @return An initialized @c SKBlob object, or @c nil if there was a problem initializing it. */
+ (instancetype)blobWithContentsOfPath:(NSString *)path;
+ (instancetype)blobWithData:(NSData *)data;
/** Callback takes an SKBlob object. Specifically for story blobs, because they're CBC encrypted and possibly zipped if it's a video. */
+ (void)blobWithStoryData:(NSData *)encryptedBlob forStory:(SKStory *)story completion:(ResponseBlock)completion;

/** Used to unarchive blobs initialized with anonymous data. Callback takes a new @c SKBlob object, and returns immediately if not compressed. */
- (void)decompress:(ResponseBlock)completion;

/** If the blob has an overlay, it will write data and overlay to a folder as @c filename/filename.[jpg|mp4] and @c filename/filename.jpg. If not, only @c data is written to the specified file. */
- (void)writeToPath:(NSString *)path filename:(NSString *)filename atomically:(BOOL)atomically;

/** The data for the image or video. */
@property (nonatomic, readonly) NSData *data;
/** @c nil if not applicable. */
@property (nonatomic, readonly) NSData *overlay;
/** @c YES if the data is for a JPEG, @c NO if it's something other than a JPEG or PNG. */
@property (nonatomic, readonly) BOOL isImage;
/** @c YES if the data is for a MPEG4 video, @c NO if it's something else. */
@property (nonatomic, readonly) BOOL isVideo;


@end
