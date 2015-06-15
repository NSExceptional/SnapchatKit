//
//  SKStory.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKThing.h"
#import "SKBlob.h"

@interface SKStory : SKThing

/** The length of the snap in seconds. */
@property (nonatomic, readonly) NSUInteger duration;

@property (nonatomic, readonly) BOOL viewed;
@property (nonatomic, readonly) BOOL shared;
@property (nonatomic, readonly) BOOL zipped;
@property (nonatomic, readonly) BOOL matureContent;
@property (nonatomic, readonly) BOOL needsAuth;

/** Fun fact: this value is just username + timestamp string. */
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSString *clientIdentifier;

@property (nonatomic, readonly) NSString    *mediaIdentifier;
@property (nonatomic, readonly) NSString    *mediaIV;
@property (nonatomic, readonly) NSString    *mediaKey;
@property (nonatomic, readonly) SKMediaKind mediaKind;
@property (nonatomic, readonly) NSURL       *mediaURL;

@property (nonatomic, readonly) NSString *thumbIV;
@property (nonatomic, readonly) NSURL    *thumbURL;

/** The number of seconds left before the story expires. */
@property (nonatomic, readonly) NSUInteger timeLeft;
@property (nonatomic, readonly) NSDate     *created;

/** @c nil until you call @c load: */
@property (nonatomic, readonly) SKBlob     *blob;
/** @c nil until you call @c loadThumbnail: */
@property (nonatomic, readonly) SKBlob     *thumbnailBlob;

@end

@interface SKStory (SKClient)
/** Loads the blob for the story. If successful, @c blob will contain the story's blob data. */
- (void)load:(ErrorBlock)completion;
/** Loads the blob for the story thumbnail. If successful, @c thumbnailBlob will contain the story's thumbnail blob data. */
- (void)loadThumbnail:(ErrorBlock)completion;
/** @return If @c blob is @c nil, returns nil. For images: @c {identifier}.jpg, for videos: @c {identifier}.mp4, and for videos with an overlay just {identifier} */
@property (nonatomic, readonly) NSString *suggestedFilename;

@end