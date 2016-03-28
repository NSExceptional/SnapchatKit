//
//  SKConnectResponsePacket.m
//  Pods
//
//  Created by Tanner on 3/25/16.
//
//

#import "SKConnectResponsePacket.h"

@implementation SKConnectResponsePacket

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"successful": @"success",
              @"identifier": @"id",
              @"failureReason": @"failure_reason",
              @"alternateServer": @"alternative_server"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ successful=%@, failure=%@, alt server=%@>",
            NSStringFromClass(self.class), @(self.successful), self.failureReason, self.alternateServer];
}

@end
