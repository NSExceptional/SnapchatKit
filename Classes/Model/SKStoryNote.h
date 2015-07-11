//
//  SKStoryNote.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"

/** Story notes carry information about how someone viewed a certain story. */
@interface SKStoryNote : SKThing

/** Who viewed the story. */
@property (nonatomic, readonly) NSString *viewer;
/** When the story was viewed by \c viewer. */
@property (nonatomic, readonly) NSDate   *viewDate;
/** Whether \c viewer took a screenshot of the story .*/
@property (nonatomic, readonly) BOOL     screenshot;

/** Obscure data. Not sure what it's all for. Keys are as follows:
    mField = "123456.023Z";
    mId    = "username~unixtime";
    mKey   = "story:{username}:YYYYMMDD";
 */
@property (nonatomic, readonly) NSDictionary *storyPointer;
 

@end
