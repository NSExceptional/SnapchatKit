//
//  SKSnapResponse.h
//  SnapchatKit
//
//  Created by Tanner on 6/29/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKThing.h"

/** Passed to the completion of both of the \c -[SKClient sendSnap:...] methods. */
@interface SKSnapResponse : SKThing

/** An array of \c SKSentSnap objects. */
@property (nonatomic, readonly) NSArray *sentSnaps;
@property (nonatomic, readonly) BOOL    success;

@end

/** Used as part of the \c SKSnapResponse class. */
@interface SKSentSnap : SKThing
@property (nonatomic, readonly) NSString *sender;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSDate   *timestamp;
@end