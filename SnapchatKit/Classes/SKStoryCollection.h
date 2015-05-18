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

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) BOOL matureContent;
/** Array of SKStory objects. */
@property (nonatomic, readonly) NSArray *stories;

@end
