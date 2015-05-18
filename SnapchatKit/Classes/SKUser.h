//
//  SKUser.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSimpleUser.h"

@interface SKUser : SKSimpleUser

@property (nonatomic, readonly) NSString *friendmoji;
@property (nonatomic, readonly) NSString *venue;
@property (nonatomic, readonly) NSString *sharedStoryIdentifier;

@property (nonatomic, readonly) BOOL canSeeCustomStories;
@property (nonatomic, readonly) BOOL needsLove;
@property (nonatomic, readonly) BOOL isSharedStory;
@property (nonatomic, readonly) BOOL hasCustomDescription;
@property (nonatomic, readonly) BOOL decayThumbnail;

@end