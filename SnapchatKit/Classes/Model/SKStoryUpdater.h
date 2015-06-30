//
//  SKStoryUpdater.h
//  SnapchatKit
//
//  Created by Tanner on 6/16/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SKStory;

/** The purpose of this class is to minimize error with the @c -markStoriesViewed: method in @c SKClient+Stories.h. */
@interface SKStoryUpdater : NSObject

+ (instancetype)viewedStory:(SKStory *)story at:(NSDate *)date screenshots:(NSUInteger)sscount;

@property (nonatomic, readonly) NSString   *storyID;
@property (nonatomic, readonly) NSString   *timestamp;
@property (nonatomic, readonly) NSUInteger screenshotCount;

@end
