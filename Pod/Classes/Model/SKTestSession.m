//
//  SKTestSession.m
//  Pods
//
//  Created by Tanner on 8/28/15.
//
//

#import "SKTestSession.h"
#import "SnapchatKit.h"

@implementation SKTestSession

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"score": @"updates_response.score",
             @"conversations": @"conversations_response",
             @"discoverSupported": @"discover.compatibility"};
}

MTLTransformPropertyMap(discoverSupported, @{@"supported": @YES})

@end
