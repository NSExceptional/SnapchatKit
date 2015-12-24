//
//  SKThing.h
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapchatKit-Constants.h"
#import "Mantle.h"

// Mantle macros //

// string to URL transform
#define MTLTransformPropertyURL(property) + (NSValueTransformer *) property##JSONTransformer { \
return [self sk_urlTransformer]; }

// ts to NSDate transform
#define MTLTransformPropertyDate(property) + (NSValueTransformer *) property##JSONTransformer { \
return [self sk_dateTransformer]; }

/// The root class of most classes in this framework.
@interface SKThing : MTLModel <MTLJSONSerializing>

- (id)initWithDictionary:(NSDictionary *)json;

/// Transforms Snapchat's UTC timestamp floats into \c NSDate.
+ (NSValueTransformer *)sk_dateTransformer;
/// Transforms strings into NSURL objects.
+ (NSValueTransformer *)sk_urlTransformer;
/// Transforms strings from "ON" and "OFF" to YES and NO.
+ (NSValueTransformer *)sk_onOffTransformer;
/// Transforms an array of dictionaries into an array of model objects of class \c cls.
+ (NSValueTransformer *)sk_modelArrayTransformerForClass:(Class)cls;
/// Transforms an array of dictionaries into an ordered set of model objects of class \c cls.
+ (NSValueTransformer *)sk_modelMutableOrderedSetTransformerForClass:(Class)cls;

/// For API debugging purposes.
+ (NSArray *)knownJSONKeys;
/// Calculated once when first accessed, using \c knownJSONKeys.
+ (NSArray *)unknownJSONKeys;
+ (NSDictionary *)allSubclassesUnknownJSONKeys;
/// Used to filter out unused JSON keys I don't want to use.
+ (NSArray *)ignoredJSONKeyPathPrefixes;

/// Transforms \c jsons to an array of model objects of class \c cls.
+ (NSArray *)transformJSONArray:(NSArray *)jsons toModelsOfClass:(Class)cls;

/// Calls into [MTLJSONAdapter JSONDictionaryFromModel:foo error:nil]
@property (readonly) NSDictionary *JSONDictionary;

@end


@protocol SKPagination <NSObject>
@property (nonatomic, readonly) NSString *pagination;
@optional
@property (nonatomic, readonly) NSDate   *created;
@property (nonatomic, readonly) NSString *conversationIdentifier;
@end