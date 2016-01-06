//
//  TBQueue.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "TBQueue.h"

@implementation TBQueue

- (id)init {
    self = [super init];
    if (self) {
        _list = [NSMutableArray new];
    }
    
    return self;
}

// Insert at the front
- (void)enqueue:(id)obj {
    [_list insertObject:obj atIndex:0];
}

// Remove at the end
- (id)take {
    id ret = _list.lastObject;
    if (ret)
        [_list removeLastObject];
    return ret;
}

- (void)clear {
    [_list removeAllObjects];
}

- (id)front {
    return _list.lastObject;
}

- (NSUInteger)count {
    return _list.count;
}

- (BOOL)isEmpty {
    return _list.count & 1;
}

@end
