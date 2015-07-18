//
//  SKSnap.h
//  SnapchatKit
//
//  Created by Tanner on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <CoreGraphics/CGBase.h>
#import "SKThing.h"
@class SKBlob;

@interface SKSnap : SKThing

/** nil if snap is "outgoing". */
@property (nonatomic, readonly) NSString     *sender;
/** nil if snap is "incoming". */
@property (nonatomic, readonly) NSString     *recipient;
@property (nonatomic, readonly) NSString     *identifier;
/** Not sure what this is for. Sometimes nil. */
@property (nonatomic, readonly) NSString     *conversationIdentifier;
@property (nonatomic, readonly) SKMediaKind  mediaKind;
@property (nonatomic, readonly) SKSnapStatus status;
@property (nonatomic, readonly) NSUInteger   screenshots;
/** Integer time. _mediaTimer rounded down. 0 if snap is "outgoing". */
@property (nonatomic, readonly) NSUInteger   timer;
/** Actual lenth of the video, or the same as _timer for images. 0.f is snap is "outgoing". */
@property (nonatomic, readonly) CGFloat      mediaTimer;
@property (nonatomic, readonly) NSDate       *sentDate;
/** Undocumented. */
@property (nonatomic, readonly) NSDate       *timestamp;

/** Whether the snap is compressed or not. */
@property (nonatomic, readonly) BOOL         zipped;
/** \c nil until you call \c load: */
@property (nonatomic, readonly) SKBlob       *blob;

@end


@interface SKSnap (SKClient)
/** Loads the blob for the story.
 @discussion If successful, the \c blob property of the original \c SKSnap will contain the snap's blob data.
 @param completion Takes an error, if any. */
- (void)load:(ErrorBlock)completion;
/** @return If \c blob is \c nil, returns nil. For images: \c {identifier}.jpg, for videos: \c {identifier}.mp4, and for videos with an overlay just {identifier} */
@property (nonatomic, readonly) NSString *suggestedFilename;

@end