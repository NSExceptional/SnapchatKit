//
//  SKStoryCollection.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKThing.h"

@interface SKStoryCollection : SKThing

/** The username of the user associated with this story collection. */
@property (nonatomic, readonly) NSString *username;
/** Whether this story contains explicit content. */
@property (nonatomic, readonly) BOOL matureContent;
/** An array of \c SKStory objects. */
@property (nonatomic, readonly) NSArray *stories;

/** The thumbnail for the viewed state of the story. */
@property (nonatomic, readonly) NSURL *viewedThumbnail;
/** The thumbnail for the unviewed state of the story. */
@property (nonatomic, readonly) NSURL *unviewedThumbnail;
@property (nonatomic, readonly) BOOL  viewedThumbNeedsAuth;
@property (nonatomic, readonly) BOOL  unviewedThumbNeedsAuth;

@property (nonatomic, readonly) NSDictionary *adPlacementData;

/** @discussion The API doesn't tell you whether an entire story is shared,
 so this method checks if the first object in it's \c stories property is \c shared. */
@property (nonatomic, readonly) BOOL isSharedStory;

@end
