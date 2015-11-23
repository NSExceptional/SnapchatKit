//
//  SKSnapOptions.h
//  SnapchatKit
//
//  Created by Tanner on 6/16/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

/** The purpose of this class is to simplify the act of sending a snpa. */
@interface SKSnapOptions : NSObject

/** If you wish, you can also just create an instance of this class with \c +new and customize it.
 @param recipients An array of username strings.
 @param text The text sent in the snap.
 @param timer The length of the snap. */
+ (instancetype)sendTo:(NSArray *)recipients text:(NSString *)text for:(NSTimeInterval)timer;

/** An array of username strings. */
@property (nonatomic) NSArray        *recipients;
/** The text sent in the snap. */
@property (nonatomic) NSString       *text;
/** Whether the camera is front facing or nit. */
@property (nonatomic) BOOL           cameraFrontFacing;
/** Whether the snap is a reply to a previous snap. */
@property (nonatomic) BOOL           isReply;
/** The length of the snap. Defaults to 3. */
@property (nonatomic) NSTimeInterval timer;

@end
