//
//  SKStoryOptions.h
//  SnapchatKitTests
//
//  Created by Harry Gulliford on 30/06/2015.
//  Copyright (c) 2015 Harry Gulliford. All rights reserved.
//

#import <Foundation/Foundation.h>

/** The purpose of this class is to simplify the act of sending a snpa. */
@interface SKStoryOptions : NSObject

/**
 If you wish, you can also just create an instance of this class with \c +new and customize it.
 @param recipients An array of username strings.
 */
+ (instancetype)storyWithText:(NSString *)text timer:(NSTimeInterval)timer;

/** An array of username strings. */
@property (nonatomic) NSString       *text;
/** Defaults to \c NO. */
@property (nonatomic) BOOL           cameraFrontFacing;
/** Defaults to 3. */
@property (nonatomic) NSTimeInterval timer;

@end
