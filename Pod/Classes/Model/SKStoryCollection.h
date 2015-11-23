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
@property (nonatomic, readonly) BOOL     matureContent;
/** An array of \c SKStory objects. */
@property (nonatomic, readonly) NSArray  *stories;


/** The display name of the shared story. @note Only applies to shared stories. */
@property (nonatomic, readonly) NSString *displayName;
/** The identifier of the shared story. @note Only applies to shared stories. */
@property (nonatomic, readonly) NSString *sharedIdentifier;
/** Whether the shared story is local or not. @note Only applies to shared stories. */
@property (nonatomic, readonly) BOOL     isLocal;

/** The thumbnail for the viewed state of the story. @note Only applies to shared stories. */
@property (nonatomic, readonly) NSURL *viewedThumbnail;
/** The thumbnail for the unviewed state of the story. @note Only applies to shared stories. */
@property (nonatomic, readonly) NSURL *unviewedThumbnail;
/** @note Only applies to shared stories. */
@property (nonatomic, readonly) BOOL  viewedThumbNeedsAuth;
/** @note Only applies to shared stories. */
@property (nonatomic, readonly) BOOL  unviewedThumbNeedsAuth;

/** @note Only applies to shared stories. */
@property (nonatomic, readonly) NSDictionary *adPlacementData;

/** @discussion The API doesn't tell you whether an entire story is shared,
 so this method checks if the first object in it's \c stories property is \c shared. */
@property (nonatomic, readonly) BOOL isSharedStory;

@end
