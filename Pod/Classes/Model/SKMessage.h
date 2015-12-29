//
//  SKMessage.h
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"

typedef NS_ENUM(NSUInteger, SKMessageKind)
{
    SKMessageKindText = 1,
    SKMessageKindMedia,
    SKMessageKindDiscoverShared,
    SKMessageKindStoryReply
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

#ifndef UIKIT_EXTERN
/** \c 0 if \c messageKind is \c SKMessageKindText. */
@property (nonatomic, readonly) NSInteger     mediaWidth;
/** \c 0 if \c messageKind is \c SKMessageKindText. */
@property (nonatomic, readonly) NSInteger     mediaHeight;
#else
/** \c {0,0} if \c messageKind is \c SKMessageKindText. */
@property (nonatomic, readonly) CGSize        mediaSize;
#endif

/** \c nil if \c messageKind is \c SKMessageKindText. */
@property (nonatomic, readonly) NSString      *mediaIV;
/** \c nil if \c messageKind is \c SKMessageKindText. */
@property (nonatomic, readonly) NSString      *mediaKey;
/** i.e. "VIDEO" or "IMAGE" */
@property (nonatomic, readonly) NSString      *mediaType;
/** The identifier of the replied-to story. \c nil unless \c messageKind is \c SKMessageKindStoryReply. */
@property (nonatomic, readonly) NSString      *storyIdentifier;
/** Whether the replied-to story is zipped. */
@property (nonatomic, readonly) BOOL          zipped;

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
