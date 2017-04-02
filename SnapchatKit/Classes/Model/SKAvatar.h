//
//  SKAvatar.h
//  Pods
//
//  Created by Tanner on 1/2/16.
//
//

#import <Foundation/Foundation.h>
#define USE_UIKIT (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#if USE_UIKIT
@import UIKit;
#else
@import AppKit;
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SKAvatar : NSObject

/** @return \c nil if an avatar could not be created from the given data. */
+ (nullable instancetype)avatarWithData:(NSData *)data error:(NSError * _Nullable *)error;
+ (NSData *)avatarDataFromImageDatas:(NSArray<NSData*> *)imageDatas;

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSDate   *lastUpdated;
@property (nonatomic, readonly) NSData   *data;

#if USE_UIKIT
/** An animated image representing the avatar. */
@property (nonatomic, readonly) UIImage *image;
#else
/** Use as you wish, \c nil by default. See \c setImage:freeFrames: */
@property (nullable, nonatomic, readonly) NSImage *image;
@property (nullable, nonatomic, readonly) NSArray<NSData*> *frames;
/** @param image The image to set to the \c image property.
    @param freeFrames Whether or not to release the \c frames property. */
- (void)setImage:(NSImage *)image freeFrames:(BOOL)freeFrames;
#endif

@end
NS_ASSUME_NONNULL_END