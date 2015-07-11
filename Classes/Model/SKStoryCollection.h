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

@end
