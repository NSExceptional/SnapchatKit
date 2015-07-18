//
//  SKThing.m
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"
#import "NSArray+SnapchatKit.h"
#import <objc/runtime.h>

#define CLASS_KEY NSStringFromClass([self class])


@interface SKThing ()
@property (nonatomic, readonly) NSDictionary *JSON;
@end

/** Dictionary of \c NSMutableSets. */
static NSMutableDictionary *_unknownJSONKeys;
/** Dictionary of \c NSMutableSets. */
static NSMutableDictionary *_knownJSONKeys;
/** Dictionary of \c NSMutableSets. */
static NSMutableDictionary *_allJSONKeys;

@implementation SKThing

- (id)initWithDictionary:(NSDictionary *)json {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _knownJSONKeys   = [NSMutableDictionary new];
        _unknownJSONKeys = [NSMutableDictionary new];
        _allJSONKeys     = [NSMutableDictionary new];
    });
    
    NSParameterAssert(json.allKeys.count > 0);
    
    self = [super init];
    if (self) {
        _JSON = json;
    }
    
    [[self class] setAllJSONKeys:self.JSON.allKeys];
    
    return self;
}

#pragma mark NSCoding protocol

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [[self.class alloc] initWithDictionary:[aDecoder decodeObjectForKey:@"json"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.JSON forKey:@"json"];
}

#pragma mark Debugging

+ (NSArray *)knownJSONKeys {
    return [_knownJSONKeys[CLASS_KEY] allObjects] ?: @[];
}

+ (void)addKnownJSONKeys:(NSArray *)keys {
    NSMutableSet *known = _knownJSONKeys[CLASS_KEY];
    if (known)
        [known addObjectsFromArray:keys];
    else
        _knownJSONKeys[CLASS_KEY] = [NSMutableSet setWithArray:keys];
}

+ (void)setAllJSONKeys:(NSArray *)keys {
    NSMutableSet *all = _allJSONKeys[CLASS_KEY];
    if (all)
        [all addObjectsFromArray:keys];
    else
        _allJSONKeys[CLASS_KEY] = [NSMutableSet setWithArray:keys];
}

+ (NSArray *)unknownJSONKeys {
    NSMutableSet *unknown = _unknownJSONKeys[CLASS_KEY];
    if (unknown)
        return unknown.allObjects;
    
    unknown = [NSMutableSet setWithArray:[_allJSONKeys[CLASS_KEY] allObjects]];
    [unknown minusSet:_knownJSONKeys[CLASS_KEY] ?: [NSSet set]];
    _unknownJSONKeys[CLASS_KEY] = unknown;
    
    return unknown.allObjects;
}

+ (NSArray *)allSubclassesUnknownJSONKeys {
    NSArray *subclasses = [self allSubclasses];
    
    NSMutableArray *allUnknownKeys = [NSMutableArray array];
    
    for (Class c in subclasses) {
        NSArray *unknown = [c unknownJSONKeys];
        if (unknown.count)
            [allUnknownKeys addObject:[NSString stringWithFormat:@"%@: %@", NSStringFromClass(c), unknown.JSONString]];
    }
    
    return allUnknownKeys;
}

+ (NSArray *)allSubclasses {
    Class *buffer = NULL;
    
    int count, size;
    do {
        count  = objc_getClassList(NULL, 0);
        buffer = (Class *)realloc(buffer, count * sizeof(*buffer));
        size   = objc_getClassList(buffer, count);
    } while(size != count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < count; i++) {
        Class candidate = buffer[i];
        Class superclass = candidate;
        while(superclass) {
            if(superclass == self) {
                [array addObject: candidate];
                break;
            }
            superclass = class_getSuperclass(superclass);
        }
    }
    
    free(buffer);
    return array;
}


@end
