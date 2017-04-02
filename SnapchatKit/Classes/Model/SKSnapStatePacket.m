//
//  SKSnapStatePacket.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKSnapStatePacket.h"


@implementation SKSnapStatePacket

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"snapIdentifier": @"snap_id",
              @"screenshotCount": @"screenshot_count",
              @"replayed": @"replayed",
              @"opened": @"viewed",
              @"timestamp": @"timestamp"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

MTLTransformPropertyDate(timestamp)

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ ss count=%@, opened=%@, id=%@>",
            NSStringFromClass(self.class), @(self.screenshotCount), @(self.opened), self.snapIdentifier];
}

@end
