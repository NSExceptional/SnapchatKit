//
//  SKClient+Stories.h
//  SnapchatKit
//
//  Created by Tanner on 6/13/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKClient.h"

@class SKStory;


@interface SKClient (Stories)

/** Callback takes an SKBlob object. */
- (void)loadStory:(SKStory *)story completion:(ResponseBlock)completion;
/** Callback takes an array of SKBlob objects. */
- (void)loadStories:(NSArray *)stories completion:(ArrayBlock)completion;

@end
