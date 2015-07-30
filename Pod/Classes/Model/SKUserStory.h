//
//  SKUserStory.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKStory.h"

@interface SKUserStory : SKStory

@property (nonatomic, readonly) NSUInteger screenshotCount;
@property (nonatomic, readonly) NSUInteger viewCount;

/** Array of SKStoryNote objects. */
@property (nonatomic, readonly) NSArray *notes;

@end
