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

/** A wrapper for the various kinds of data used throughout the API. */
@interface SKBlob : NSObject

/** Initializes a blob with the snap found at \c path.
 @discussion \c path can be a path to a folder (containing a video and overlay) or a single snap.
 @param path The path to a single snap or a folder containing a video and overlay.
 @return An initialized \c SKBlob object, or \c nil if there was a problem initializing it. If \c path is a directory, this method will look for the contents of unzipped media specifically. */
+ (instancetype)blobWithContentsOfPath:(NSString *)path;
/** Initializes a blob with anonymous data. */
+ (instancetype)blobWithData:(NSData *)data;
/** Initializes a blob with story data and passes it to the completion block.
 @discussion This method is specifically for story blobs, because they \e used to be CBC encrypted and possibly zipped if it's a video. Yes: stories are no longer encrypted. Get it together, Snapchat...
 @param blobData Pretty self explanatory.
 @param story The story you wish to retrieve.
 @param completion Takes an error, if any, and an \c SKBlob object. */
+ (void)blobWithStoryData:(NSData *)blobData forStory:(SKStory *)story completion:(ResponseBlock)completion;

/** Used to unarchive blobs initialized with anonymous data.
@param completion Takes an error, if any, and new \c SKBlob object. Returns immediately if the blob was not compressed. */
- (void)decompress:(ResponseBlock)completion;

/** Conveniently writes all data associated with the \c SKBlob object to the disk.
 @discussion If the blob has an overlay, this method will write the data and overlay to a folder as \c filename/filename.[jpg|mp4] and \c filename/filename.jpg.
 If not, only \c data is written to the specified file.
 @param path The \e directory to which to write the receiver's bytes. Pass the desired filename to \e filename. See \c -[NSData writeToFile:atomically:] for more information.
 @param filename The name to serialize the blob under.
 @param atomically See \c -[NSData writeToFile:atomically:]
 @return An array of strings paths to the written files. Overlay is always the second object if applicable. */
- (NSArray *)writeToPath:(NSString *)directoryPath filename:(NSString *)filename atomically:(BOOL)atomically;

/** The data for the image or video. */
@property (nonatomic, readonly) NSData *data;
/** The overlay for the video. \c nil if not applicable. */
@property (nonatomic, readonly) NSData *overlay;
/** \c YES if the data is for a JPEG, \c NO if it's something other than a JPEG or PNG. */
@property (nonatomic, readonly) BOOL isImage;
/** \c YES if the data is for a MPEG4 video, \c NO if it's something else. */
@property (nonatomic, readonly) BOOL isVideo;


@end
