//
//  SKPingResponsePacket.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKPingResponsePacket.h"


@implementation SKPingResponsePacket

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [@{@"pingIdentifier": @"ping_id"} mtl_dictionaryByAddingEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ id=%@>",
            NSStringFromClass(self.class), self.pingIdentifier];
}

@end
