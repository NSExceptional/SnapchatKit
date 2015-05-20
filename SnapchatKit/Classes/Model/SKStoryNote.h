//
//  SKStoryNote.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"

@interface SKStoryNote : SKThing

@property (nonatomic, readonly) NSString *viewer;
@property (nonatomic, readonly) NSDate   *viewDate;
@property (nonatomic, readonly) BOOL     screenshot;

/**
 Obscure data. Not sure what it's all for. Keys are as follows:
    mField = "123456.023Z";
    mId    = "username~unixtime";
    mKey   = "story:{username}:YYYYMMDD";
 */
@property (nonatomic, readonly) NSDictionary *storyPointer;
 

@end
