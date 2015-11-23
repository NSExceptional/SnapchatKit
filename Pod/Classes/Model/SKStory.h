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

/** The username of whoever posted this story. */
@property (nonatomic, readonly) NSString *author;

/** The length of the snap in seconds. */
@property (nonatomic, readonly) NSUInteger duration;

/** Whether the story has been viewed. */
@property (nonatomic, readonly) BOOL viewed;
/** Whether the story is a "live" or "shared" story. */
@property (nonatomic, readonly) BOOL shared;
/** Whether the story is zipped (video stories with an overlay will be zipped). */
@property (nonatomic, readonly) BOOL zipped;
/** Whether the story contains explicit content. */
@property (nonatomic, readonly) BOOL matureContent;
/** Not sure. */
@property (nonatomic, readonly) BOOL needsAuth;

/** The story's ID. Fun fact: this value is just username + timestamp string. */
@property (nonatomic, readonly) NSString    *identifier;
/** The text of the story. */
@property (nonatomic, readonly) NSString    *text;
/** Not sure. */
@property (nonatomic, readonly) NSString    *clientIdentifier;

/** Unknown */
@property (nonatomic, readonly) NSString    *storyFilterIdentifier;
/** Unknown */
@property (nonatomic, readonly) BOOL        adCanFollow;

/** The story's media ID. */
@property (nonatomic, readonly) NSString    *mediaIdentifier;
/** The IV used to decrypt the media. */
@property (nonatomic, readonly) NSString    *mediaIV;
/** The key used to decrypt the media. */
@property (nonatomic, readonly) NSString    *mediaKey;
@property (nonatomic, readonly) SKMediaKind mediaKind;
/** The URL of the media. */
@property (nonatomic, readonly) NSURL       *mediaURL;

/** The IV used to decrypt the thumbnail. */
@property (nonatomic, readonly) NSString    *thumbIV;
/** The URL of the thumbnail. */
@property (nonatomic, readonly) NSURL       *thumbURL;

/** The number of seconds left before the story expires. */
@property (nonatomic, readonly) NSUInteger  timeLeft;
/** The date the story was created. */
@property (nonatomic, readonly) NSDate      *created;

/** \c nil until you call \c load: */
@property (nonatomic, readonly) SKBlob      *blob;
/** \c nil until you call \c loadThumbnail: */
@property (nonatomic, readonly) SKBlob      *thumbnailBlob;

@end

@interface SKStory (SKClient)
/** Loads the blob for the story. If successful, the \c blob property of the original \c SKStory object will contain the story's blob data.
 @param completion Takes an error, if any. */
- (void)load:(ErrorBlock)completion;
/** Loads the blob for the story thumbnail. If successful, the \c thumbnailBlob property of the original \c SKStory object will contain the story's thumbnail blob data.
@param completion Takes an error, if any. */
- (void)loadThumbnail:(ErrorBlock)completion;
/** @return If \c blob is \c nil, returns nil. For images: \c {identifier}.jpg, for videos: \c {identifier}.mp4, and for videos with an overlay just {identifier} */
@property (nonatomic, readonly) NSString *suggestedFilename;

@end