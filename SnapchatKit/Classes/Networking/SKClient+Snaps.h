//
//  SKClient+Snaps.h
//  SnapchatKit
//
//  Created by Tanner on 5/26/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKClient.h"
#import "SKSnap.h"

@interface SKClient (Snaps)

- (void)markSnapViewed:(NSString *)identifier for:(NSUInteger)secondsViewed completion:(BooleanBlock)completion;

/** callback takes an SKBlob object. */
- (void)loadSnap:(SKSnap *)snap completion:(ResponseBlock)completion;
/** callback takes an SKBlob object. */
- (void)loadSnapWithIdentifier:(NSString *)identifier completion:(ResponseBlock)completion;

@end

@interface SKSnap (Networking)
/** callback takes an SKBlob object. */
- (void)loadMediaWithCompletion:(ResponseBlock)completion;
@end