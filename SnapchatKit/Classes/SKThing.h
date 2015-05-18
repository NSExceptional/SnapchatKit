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

@end
