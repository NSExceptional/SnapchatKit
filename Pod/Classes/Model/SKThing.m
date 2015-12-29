//
//  SKThing.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKThing.h"
#import "NSArray+SnapchatKit.h"
#import "NSDictionary+SnapchatKit.h"
#import <objc/runtime.h>

#define CLASS_KEY NSStringFromClass(self.class)


@interface SKThing ()
@property (nonatomic, readonly) NSDictionary *JSON;
@end

/** Dictionary of \c NSMutableSets. */
static NSMutableDictionary *_knownJSONKeys;
/** Dictionary of \c NSMutableSets. */
static NSMutableDictionary *_allJSONKeys;

@implementation SKThing

- (id)initWithDictionary:(NSDictionary *)json {
    NSParameterAssert(json.allKeys.count > 0);
    NSError *error = nil;
    self = [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:json error:&error];
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    
#if kDebugJSON
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _knownJSONKeys   = [NSMutableDictionary new];
        _allJSONKeys     = [NSMutableDictionary new];
    });
    if (self) {
        _JSON = json;
        [self.class setAllJSONKeys:json.allKeyPaths];
        [self.class addKnownJSONKeys:[self.class JSONKeyPathsByPropertyKey].allValues];
    }
#endif
    
    return self;
}

#pragma mark Debugging

+ (NSArray *)knownJSONKeys {
    return [_knownJSONKeys[CLASS_KEY] allObjects] ?: @[];
}

+ (NSArray *)unknownJSONKeys {
    NSMutableSet *unknown = [NSMutableSet setWithArray:[_allJSONKeys[CLASS_KEY] allObjects]];
    NSArray *ignored = [self ignoredJSONKeyPathPrefixes];
    [unknown minusSet:_knownJSONKeys[CLASS_KEY] ?: [NSSet set]];
    
    NSMutableSet *unknownWithoutIgnored = unknown.mutableCopy;
    
    for (NSString *prefix in ignored)
        for (NSString *key in unknown)
            if ([key hasPrefix:prefix])
                [unknownWithoutIgnored removeObject:key];
    
    unknown = unknownWithoutIgnored.mutableCopy;
    
    for (NSString *prefix in unknown)
        for (NSString *fullKey in [self knownJSONKeys])
            if ([fullKey hasPrefix:prefix])
                [unknownWithoutIgnored removeObject:prefix];
    
    return unknownWithoutIgnored.allObjects;
}

+ (NSArray *)ignoredJSONKeyPathPrefixes { return @[]; }

+ (void)setAllJSONKeys:(NSArray *)keys {
    NSMutableSet *all = _allJSONKeys[CLASS_KEY];
    if (all)
        [all addObjectsFromArray:keys];
    else
        _allJSONKeys[CLASS_KEY] = [NSMutableSet setWithArray:keys];
}

+ (void)addKnownJSONKeys:(NSArray *)keys {
    NSMutableSet *known = _knownJSONKeys[CLASS_KEY];
    if (known)
        [known addObjectsFromArray:keys];
    else
        _knownJSONKeys[CLASS_KEY] = [NSMutableSet setWithArray:keys];
}

- (NSDictionary *)JSONDictionary {
    return [MTLJSONAdapter JSONDictionaryFromModel:self error:nil];
}

+ (NSDictionary *)allSubclassesUnknownJSONKeys {
    NSArray *subclasses = [self allSubclasses];
    
    NSMutableDictionary *allUnknownKeys = [NSMutableDictionary dictionary];
    
    for (Class c in subclasses) {
        NSArray *unknown = [c unknownJSONKeys];
        if (unknown.count)
            allUnknownKeys[NSStringFromClass(c)] = [unknown sortedArrayUsingSelector:@selector(compare:)];
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

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{};
}

+ (NSValueTransformer *)sk_dateTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *ts, BOOL *success, NSError *__autoreleasing *error) {
        return ts.doubleValue > 0 ? [NSDate dateWithTimeIntervalSince1970:ts.doubleValue/1000.f] : nil;
    } reverseBlock:^id(NSDate *ts, BOOL *success, NSError *__autoreleasing *error) {
        return ts ? @([ts timeIntervalSince1970] * 1000.f).stringValue : nil;
    }];
}

+ (NSValueTransformer *)sk_urlTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)sk_onOffTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{@"ON": @YES, @"OFF": @NO} defaultValue:@NO reverseDefaultValue:@"OFF"];
}

+ (NSValueTransformer *)sk_modelArrayTransformerForClass:(Class)cls {
    NSParameterAssert([(id)[cls class] isSubclassOfClass:[SKThing class]]);
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *dictionaries, BOOL *success, NSError *__autoreleasing *error) {
        NSMutableArray *models = [NSMutableArray new];
        for (NSDictionary *dict in dictionaries)
            [models addObject:[[cls alloc] initWithDictionary:dict]];
        return models.copy;
    } reverseBlock:^id(NSArray *models, BOOL *success, NSError *__autoreleasing *error) {
        return models.dictionaryValues;
    }];
}

+ (NSValueTransformer *)sk_modelMutableOrderedSetTransformerForClass:(Class)cls {
    NSParameterAssert([(id)[cls class] isSubclassOfClass:[SKThing class]]);
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *dictionaries, BOOL *success, NSError *__autoreleasing *error) {
        NSMutableOrderedSet *models = [NSMutableOrderedSet orderedSet];
        for (NSDictionary *dict in dictionaries)
            [models addObject:[[cls alloc] initWithDictionary:dict]];
        return models;
    } reverseBlock:^id(NSMutableOrderedSet *models, BOOL *success, NSError *__autoreleasing *error) {
        return models.array.dictionaryValues;
    }];
}

+ (NSArray *)transformJSONArray:(NSArray *)jsons toModelsOfClass:(Class)cls {
    NSParameterAssert(jsons.count); NSParameterAssert(cls);
    NSMutableArray *temp = [NSMutableArray array];
    for (NSDictionary *json in jsons)
        [temp addObject:[[cls alloc] initWithDictionary:json]];
    
    return temp.copy;
}


@end
