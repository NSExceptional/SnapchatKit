//
//  SKBlob.h
//  SnapchatKit
//
//  Created by Tanner on 6/13/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKBlob : NSObject

/**
 path can be a path to a folder (containing a video and overlay) or a single snap.
 @return An initialized @c SKBlob object, or @c nil if there was a problem initializing it. */
+ (instancetype)blobWithContentsOfPath:(NSString *)path;
+ (instancetype)blobWithData:(NSData *)data;

/** If the blob has an overlay, it will write data and overlay to a folder as @c media.[jpg|mp4] and @c overlay.jpg. If not, only @c data is written to the specified file. */
- (void)writeToPath:(NSString *)path atomically:(BOOL)atomically;

/** The data for the image or video. */
@property (nonatomic, readonly) NSData *data;
/** @c nil if not applicable. */
@property (nonatomic, readonly) NSData *overlay;
/** @c YES if the data is for a JPEG, @c NO if it's something other than a JPEG (most likely to be an MPEG4). */
@property (nonatomic, readonly) BOOL isImage;


@end
