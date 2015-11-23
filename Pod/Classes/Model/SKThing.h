//
//  SKThing.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapchatKit-Constants.h"
#import "Mantle.h"

// Mantle macros //

// string to URL transform
#define MTLTransformPropertyURL(property) + (NSValueTransformer *) property##JSONTransformer { \
return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName]; }

// class transform
#define MTLTransformPropertyClass(property, cls) + (NSValueTransformer *) property##JSONTransformer { \
return [MTLJSONAdapter dictionaryTransformerWithModelClass:[ cls class]]; }

// dictionary transform
#define MTLTransformPropertyMap(property, dictionary) + (NSValueTransformer *) property##JSONTransformer { \
return [NSValueTransformer mtl_valueMappingTransformerWithDictionary: dictionary ]; }


/** The root class of most classes in this framework. */
@interface SKThing : MTLModel <MTLJSONSerializing>

- (id)initWithDictionary:(NSDictionary *)json;

+ (NSValueTransformer *)sk_dateTransformer;

/** 
 For API debugging purposes, each class adds it's known
 JSON keys to this so we can find ones we aren't
 using or don't know about.
 
 It is a dictionary of mutable sets, mapped by class names.
 */
+ (NSArray *)knownJSONKeys;
+ (void)addKnownJSONKeys:(NSArray *)keys;
+ (void)setAllJSONKeys:(NSArray *)keys;

/** Calculated once when first accessed, using \c knownJSONKeys. */
+ (NSArray *)unknownJSONKeys;
/** Calculated when called. */
+ (NSArray *)allSubclassesUnknownJSONKeys;

@end


@protocol SKPagination <NSObject>
@property (nonatomic, copy, readonly) NSString *pagination;
@optional
@property (nonatomic, copy, readonly) NSDate   *created;
@property (nonatomic, copy, readonly) NSString *conversationIdentifier;
@end