//
//  SKThing.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapchatKit-Constants.h"

/** The root class of most classes in this framework. */
@interface SKThing : NSObject <NSCoding>

- (id)initWithDictionary:(NSDictionary *)json;

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
@property (nonatomic, readonly) NSString *pagination;
@optional
@property (nonatomic, readonly) NSDate   *created;
@property (nonatomic, readonly) NSString *conversationIdentifier;
@end