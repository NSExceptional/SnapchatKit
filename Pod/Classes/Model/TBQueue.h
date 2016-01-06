//
//  TBQueue.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface TBQueue<__covariant ObjectType> : NSObject {
    @private
    NSMutableArray *_list;
}

/// Adds obj to the end of the queue.
- (void)enqueue:(nonnull ObjectType)obj;
/// Dequeues and returns the fist object in the queue, reutrns \c nil if empty.
- (nullable ObjectType)take;
/// Empties the queue.
- (void)clear;

@property (nonatomic, readonly, nullable) ObjectType front;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) BOOL isEmpty;

@end
NS_ASSUME_NONNULL_END
