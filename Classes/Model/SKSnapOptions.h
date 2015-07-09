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

/**
 If you wish, you can also just create an instance of this class with @c +new and customize it.
 @param recipients An array of username strings.
 */
+ (instancetype)sendTo:(NSArray *)recipients text:(NSString *)text for:(NSTimeInterval)timer;

/** An array of username strings. */
@property (nonatomic) NSArray        *recipients;
@property (nonatomic) NSString       *text;
@property (nonatomic) BOOL           cameraFrontFacing;
@property (nonatomic) BOOL           isReply;
/** Defaults to 3. */
@property (nonatomic) NSTimeInterval timer;

@end
