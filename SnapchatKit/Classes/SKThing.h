//
//  SKThing.h
//  SnapchatKit
//
//  Created by Tanner on 5/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapchatKit-Constants.h"

@interface SKThing : NSObject <NSCoding>

- (id)initWithDictionary:(NSDictionary *)json;

/** 
 For API debugging purposes, each class adds it's known
 JSON keys to this array so we can find ones we aren't
 using or don't know about.
 */
@property (nonatomic) NSMutableArray *knownJSONKeys;

/** Calculated once when first accessed, using _knownJSONKeys. */
@property (nonatomic, readonly) NSArray *unknownJSONKeys;

@end
