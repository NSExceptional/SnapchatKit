//
//  SKCashTransaction.h
//  SnapchatKit
//
//  Created by Tanner on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"

/** Represents a cash transaction via chat. */
@interface SKCashTransaction : SKThing <SKPagination>

// SKPagination properties //

@property (nonatomic, readonly) NSString     *conversationIdentifier;
@property (nonatomic, readonly) NSString     *pagination;
@property (nonatomic, readonly) NSDate       *created;


@property (nonatomic, readonly) SKSnapStatus status;
/** The transaction amount in cents (in US). */
@property (nonatomic, readonly) NSUInteger   amount;
/** Example: "USD". */
@property (nonatomic, readonly) NSString     *currencyCode;
@property (nonatomic, readonly) BOOL         invisible;
@property (nonatomic, readonly) NSDate       *lastUpdated;
/** Example: "$2.50". */
@property (nonatomic, readonly) NSString     *message;
/** No idea */
@property (nonatomic, readonly) BOOL         rain;

@property (nonatomic, readonly) NSString     *identifier;

@property (nonatomic, readonly) NSString     *recipient;
@property (nonatomic, readonly) NSString     *recipientIdentifier;
@property (nonatomic, readonly) NSInteger    recipientSaveVersion;
@property (nonatomic, readonly) BOOL         recipientSaved;
@property (nonatomic, readonly) BOOL         recipientViewed;

@property (nonatomic, readonly) NSString     *sender;
@property (nonatomic, readonly) NSString     *senderIdentifier;
@property (nonatomic, readonly) NSInteger    senderSaveVersion;
@property (nonatomic, readonly) BOOL         senderSaved;
@property (nonatomic, readonly) BOOL         senderViewed;

@end