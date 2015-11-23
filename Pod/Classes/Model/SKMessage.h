//
//  SKMessage.h
//  SnapchatKit
//
//  Created by Tanner on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"
#import <CoreGraphics/CGGeometry.h>

typedef NS_ENUM(NSUInteger, SKMessageKind)
{
    SKMessageKindText = 1,
    SKMessageKindMedia,
    SKMessageKindDiscoverShared
};

extern SKMessageKind SKMessageKindFromString(NSString *messageKindString);

@interface SKMessage : SKThing <SKPagination>

// SKPagination
@property (nonatomic, readonly) NSString      *pagination;
@property (nonatomic, readonly) NSString      *conversationIdentifier;
@property (nonatomic, readonly) NSDate        *created;

/** Use this property to mark a message as read. */
@property (nonatomic, readonly) NSString      *identifier;
@property (nonatomic, readonly) NSString      *messageIdentifier;
@property (nonatomic, readonly) SKMessageKind messageKind;

/** \c nil if \c messageKind is \c SKMessageKindMedia. */
@property (nonatomic, readonly) NSString      *text;

/** \c nil if \c messageKind is \c SKMessageKindText. */
@property (nonatomic, readonly) NSString      *mediaIdentifier;
/** \c {0,0} if \c messageKind is \c SKMessageKindText. */
@property (nonatomic, readonly) CGSize        mediaSize;
/** \c nil if \c messageKind is \c SKMessageKindText. */
@property (nonatomic, readonly) NSString      *mediaIV;
/** \c nil if \c messageKind is \c SKMessageKindText. */
@property (nonatomic, readonly) NSString      *mediaKey;
/** i.e. "VIDEO" */
@property (nonatomic, readonly) NSString      *mediaType;

/** Array of usernames. */
@property (nonatomic, readonly) NSArray       *recipients;
@property (nonatomic, readonly) NSString      *sender;

/** The position of this message in the conversation. i.e. 1 if it is the first message. */
@property (nonatomic, readonly) NSUInteger    index;

/** Keys for each participant mapped to dictionaries with keys "saved" and "version". */
@property (nonatomic, readonly) NSDictionary  *savedState;

/** So far, it's just "chat_message". Odd. */
@property (nonatomic, readonly) NSString      *type;


@end
