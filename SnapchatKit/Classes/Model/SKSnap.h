//
//  SKSnap.h
//  SnapchatKit
//
//  Created by Tanner on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"

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

@end