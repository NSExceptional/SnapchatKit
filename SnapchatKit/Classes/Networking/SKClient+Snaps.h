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

- (void)loadSnap:(SKSnap *)snap completion:(DataBlock)completion;
- (void)loadSnapWithIdentifier:(NSString *)identifier completion:(DataBlock)completion;

@end

@interface SKSnap (Networking)
- (void)loadMediaWithCompletion:(DataBlock)completion;
@end